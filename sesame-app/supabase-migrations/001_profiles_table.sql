-- ═══════════════════════════════════════════════════════════
-- TABLE profiles — Sésame 2026
-- À exécuter dans Supabase Dashboard > SQL Editor
-- ═══════════════════════════════════════════════════════════

-- 1. Créer la table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  paid BOOLEAN NOT NULL DEFAULT false,
  is_admin BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. RLS : activer et autoriser la lecture pour l'utilisateur connecté
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Chaque user peut lire SA propre ligne (pour le check paid)
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Seuls les admins peuvent modifier (via dashboard ou service_role)
-- Pas de policy INSERT/UPDATE pour anon/authenticated → sécurisé

-- 3. Trigger : créer automatiquement un profil à l'inscription
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

-- Supprimer le trigger s'il existe déjà
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Insérer ton profil admin (si ton compte existe déjà)
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, true, true
FROM auth.users
WHERE email = 'kevinou1707@gmail.com'
ON CONFLICT (id) DO UPDATE SET paid = true, is_admin = true;

-- 5. Insérer les profils pour les comptes existants (non payés)
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, false, false
FROM auth.users
WHERE email != 'kevinou1707@gmail.com'
ON CONFLICT (id) DO NOTHING;
