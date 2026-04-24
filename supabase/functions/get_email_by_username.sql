-- Login per Benutzername: gibt die E-Mail-Adresse für einen gegebenen Benutzernamen zurück.
-- SECURITY DEFINER damit auth.users lesbar ist.
-- Manuell im Supabase SQL Editor ausführen.

CREATE OR REPLACE FUNCTION get_email_by_username(p_username text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email text;
BEGIN
  SELECT au.email INTO v_email
  FROM profiles p
  JOIN auth.users au ON au.id = p.id
  WHERE lower(p.username) = lower(p_username)
  LIMIT 1;

  RETURN v_email;
END;
$$;
