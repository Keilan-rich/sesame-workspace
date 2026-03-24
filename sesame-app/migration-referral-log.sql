-- Table de log: chaque clic referral est enregistré
CREATE TABLE IF NOT EXISTS referral_logs (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ref_code TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE referral_logs ENABLE ROW LEVEL SECURITY;

-- Users can insert their own logs (for tracking)
CREATE POLICY "Users can insert own referral logs" ON referral_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Admins can read all logs
CREATE POLICY "Admins can read referral logs" ON referral_logs
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
  );

-- Update admin RPC to also return referral history
CREATE OR REPLACE FUNCTION admin_get_referral_logs()
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  ref_code TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true
  ) THEN
    RAISE EXCEPTION 'Accès refusé — admin uniquement';
  END IF;

  RETURN QUERY
    SELECT rl.user_id, p.email, rl.ref_code, rl.created_at
    FROM referral_logs rl
    JOIN profiles p ON p.id = rl.user_id
    ORDER BY rl.created_at DESC;
END;
$$;
