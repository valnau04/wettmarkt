-- 1. Spalte hinzufügen (idempotent)
ALTER TABLE markets ADD COLUMN IF NOT EXISTS hidden boolean NOT NULL DEFAULT false;

-- 2. RPC: toggle_market_hidden
CREATE OR REPLACE FUNCTION toggle_market_hidden(p_market_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_role user_role;
  v_new_hidden boolean;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = auth.uid();
  IF v_role != 'admin' THEN
    RAISE EXCEPTION 'Nur Admins können Märkte verstecken.';
  END IF;

  UPDATE markets
  SET hidden = NOT hidden, updated_at = now()
  WHERE id = p_market_id AND status = 'active'
  RETURNING hidden INTO v_new_hidden;

  IF v_new_hidden IS NULL THEN
    RAISE EXCEPTION 'Markt nicht gefunden oder nicht aktiv.';
  END IF;

  RETURN json_build_object('hidden', v_new_hidden);
END;
$$;
