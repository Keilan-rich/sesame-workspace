-- 1. Table profiles
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  paid BOOLEAN NOT NULL DEFAULT false,
  is_admin BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- 2. Trigger function (inserts profile on signup)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
  v_id UUID;
  v_email TEXT;
  v_admin BOOLEAN;
BEGIN
  v_id    := NEW.id;
  v_email := NEW.email;
  v_admin := (v_email = 'kevinou1707@gmail.com');

  INSERT INTO public.profiles (id, email, paid, is_admin)
  VALUES (v_id, v_email, v_admin, v_admin);

  RETURN NEW;
END;
$func$;

-- 3. Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Seed: ton compte = admin + paid
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, true, true
FROM auth.users
WHERE email = 'kevinou1707@gmail.com'
ON CONFLICT (id) DO UPDATE SET paid = true, is_admin = true;

-- 5. Seed: autres utilisateurs existants
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, false, false
FROM auth.users
WHERE NOT (email = 'kevinou1707@gmail.com')
ON CONFLICT (id) DO NOTHING;
