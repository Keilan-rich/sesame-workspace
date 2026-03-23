-- Migration: Ajout authentification per-user
-- À exécuter dans Supabase Dashboard > SQL Editor

-- 1. Colonnes user_id
ALTER TABLE daily_sessions ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE session_results ADD COLUMN IF NOT EXISTS user_id UUID;

-- 2. Colonne revision_ids pour tracker les questions de révision
ALTER TABLE daily_sessions ADD COLUMN IF NOT EXISTS revision_ids TEXT[];

-- 2b. Colonne session_type dans session_results (pour filtrer par type de session)
ALTER TABLE session_results ADD COLUMN IF NOT EXISTS session_type TEXT DEFAULT 'daily';

-- 3. Contrainte unique par (date, user, type) au lieu de date seule
ALTER TABLE daily_sessions DROP CONSTRAINT IF EXISTS daily_sessions_date_key;
ALTER TABLE daily_sessions ADD CONSTRAINT daily_sessions_date_user_type_unique
  UNIQUE (date, user_id, session_type);

-- 4. Supprimer anciennes policies anonymes
DROP POLICY IF EXISTS "Allow anonymous read" ON daily_sessions;
DROP POLICY IF EXISTS "Allow anonymous insert" ON daily_sessions;
DROP POLICY IF EXISTS "Allow anonymous read" ON session_results;
DROP POLICY IF EXISTS "Allow anonymous insert" ON session_results;

-- 5. Nouvelles RLS policies per-user
CREATE POLICY "Users read own sessions" ON daily_sessions
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users insert own sessions" ON daily_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users read own results" ON session_results
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users insert own results" ON session_results
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. Activer RLS si pas déjà fait
ALTER TABLE daily_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_results ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════
-- TABLE profiles — Paywall / Accès payant
-- ═══════════════════════════════════════════════════════════

-- 7. Créer la table profiles
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  paid BOOLEAN NOT NULL DEFAULT false,
  is_admin BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. RLS : chaque user peut lire SA propre ligne uniquement
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Pas de policy INSERT/UPDATE pour authenticated → personne ne peut se mettre paid=true

-- 9. Trigger : créer automatiquement un profil à chaque inscription
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 10. Insérer ton profil admin (si ton compte existe déjà)
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, true, true
FROM auth.users
WHERE email = 'kevinou1707@gmail.com'
ON CONFLICT (id) DO UPDATE SET paid = true, is_admin = true;

-- 11. Insérer les profils pour les comptes existants (non payés)
INSERT INTO profiles (id, email, paid, is_admin)
SELECT id, email, false, false
FROM auth.users
WHERE email != 'kevinou1707@gmail.com'
ON CONFLICT (id) DO NOTHING;
