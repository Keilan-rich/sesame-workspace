-- Migration: Referral tracking
-- Ajoute une colonne referred_by à profiles pour traquer quel ambassadeur a amené l'utilisateur

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS referred_by TEXT DEFAULT NULL;

-- Index pour requêter facilement par code referral
CREATE INDEX IF NOT EXISTS idx_profiles_referred_by ON profiles(referred_by) WHERE referred_by IS NOT NULL;

-- Vue utile : nombre d'inscrits par ambassadeur
CREATE OR REPLACE VIEW referral_stats AS
SELECT
  referred_by,
  COUNT(*) AS total_signups,
  COUNT(*) FILTER (WHERE paid = true) AS total_paid,
  MAX(created_at) AS last_signup
FROM profiles
WHERE referred_by IS NOT NULL
GROUP BY referred_by
ORDER BY total_signups DESC;
