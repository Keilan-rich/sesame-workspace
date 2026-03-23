-- Table profiles
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

-- Trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, paid, is_admin)
  VALUES (
    NEW.id,
    NEW.email,
    CASE WHEN NEW.email = 'kevinou1707@gmail.com' THEN true ELSE false END,
    CASE WHEN NEW.email = 'kevinou1707@gmail.com' THEN true ELSE false END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Seed existing users
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, true, true
FROM auth.users
WHERE email = 'kevinou1707@gmail.com'
ON CONFLICT (id) DO UPDATE SET paid = true, is_admin = true;

INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, false, false
FROM auth.users
WHERE email != 'kevinou1707@gmail.com'
ON CONFLICT (id) DO NOTHING;
