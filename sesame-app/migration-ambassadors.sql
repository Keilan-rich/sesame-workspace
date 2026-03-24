-- Table pour stocker les ambassadeurs créés
CREATE TABLE IF NOT EXISTS ambassadors (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE ambassadors ENABLE ROW LEVEL SECURITY;

-- Seuls les admins peuvent lire/écrire
CREATE POLICY "Admins can manage ambassadors" ON ambassadors
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
  );
