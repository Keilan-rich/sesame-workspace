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
