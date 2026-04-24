-- =====================================================
-- TRANSACTION HISTORY + ADMIN BALANCE ADJUSTMENT
-- =====================================================

-- 1) Tabelle für Admin-Guthabenanpassungen
CREATE TABLE IF NOT EXISTS balance_adjustments (
  id         uuid        DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id    uuid        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount     numeric     NOT NULL,
  note       text,
  admin_id   uuid        REFERENCES profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE balance_adjustments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_read_own_adjustments" ON balance_adjustments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "admin_insert_adjustments" ON balance_adjustments
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- 2) RPC: Transaktionshistorie für einen User abrufen
CREATE OR REPLACE FUNCTION get_transaction_history(
  p_user_id uuid,
  p_limit   int DEFAULT 31,
  p_offset  int DEFAULT 0
)
RETURNS TABLE (
  id           uuid,
  tx_type      text,
  amount       numeric,
  description  text,
  market_id    uuid,
  market_title text,
  created_at   timestamptz
)
LANGUAGE sql SECURITY DEFINER
AS $$
  SELECT *
  FROM (
    -- Wetteinsätze (Ausgaben)
    SELECT
      tl.id,
      'trade'::text                          AS tx_type,
      -tl.investment_amount                  AS amount,
      CASE tl.direction
        WHEN 'yes' THEN 'Wette: JA'
        WHEN 'no'  THEN 'Wette: NEIN'
        ELSE            'Wette'
      END                                    AS description,
      tl.market_id,
      m.title                                AS market_title,
      tl.timestamp                           AS created_at
    FROM trade_logs tl
    JOIN markets m ON m.id = tl.market_id
    WHERE tl.user_id = p_user_id

    UNION ALL

    -- Auszahlungen (Einnahmen)
    SELECT
      pl.id,
      'payout'::text                         AS tx_type,
      pl.payout_amount                       AS amount,
      'Auszahlung'::text                     AS description,
      pl.market_id,
      m.title                                AS market_title,
      pl.paid_at                             AS created_at
    FROM payout_logs pl
    JOIN markets m ON m.id = pl.market_id
    WHERE pl.user_id = p_user_id

    UNION ALL

    -- Admin-Guthabenanpassungen
    SELECT
      ba.id,
      'adjustment'::text                     AS tx_type,
      ba.amount,
      COALESCE(ba.note, 'Admin-Anpassung')   AS description,
      NULL::uuid                             AS market_id,
      NULL::text                             AS market_title,
      ba.created_at
    FROM balance_adjustments ba
    WHERE ba.user_id = p_user_id
  ) AS combined
  ORDER BY created_at DESC
  LIMIT  p_limit
  OFFSET p_offset;
$$;

-- 3) RPC: Admin passt Guthaben eines Users an
CREATE OR REPLACE FUNCTION admin_adjust_balance(
  p_user_id uuid,
  p_amount  numeric,
  p_note    text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_role user_role;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = auth.uid();
  IF v_role <> 'admin' THEN
    RAISE EXCEPTION 'Nur Admins können Guthaben anpassen.';
  END IF;

  UPDATE profiles SET balance = balance + p_amount WHERE id = p_user_id;

  INSERT INTO balance_adjustments (user_id, amount, note, admin_id)
  VALUES (p_user_id, p_amount, p_note, auth.uid());
END;
$$;
