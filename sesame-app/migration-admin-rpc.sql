-- Migration: Admin RPC function to read all profiles
-- Only callable by users where profiles.is_admin = true

CREATE OR REPLACE FUNCTION admin_get_profiles()
RETURNS TABLE (
  id UUID,
  email TEXT,
  paid BOOLEAN,
  is_admin BOOLEAN,
  referred_by TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check caller is admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true
  ) THEN
    RAISE EXCEPTION 'Accès refusé — admin uniquement';
  END IF;

  RETURN QUERY
    SELECT p.id, p.email, p.paid, p.is_admin, p.referred_by, p.created_at
    FROM profiles p
    ORDER BY p.created_at DESC;
END;
$$;

-- Also allow admins to update any profile (to mark users as paid)
CREATE POLICY "Admins can update all profiles" ON profiles
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
  );

-- Allow users to update their own referred_by (for referral tracking)
CREATE POLICY "Users can update own referred_by" ON profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
