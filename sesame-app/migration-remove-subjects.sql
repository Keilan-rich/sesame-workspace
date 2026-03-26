-- Migration: Retirer Espagnol et Analyse documentaire du calendrier
-- Raison: pas de questions d'entraînement disponibles pour ces matières
-- Date: 2026-03-26

-- 1. Retirer 'espagnol' et 'analyse_doc' des arrays subjects dans calendar
UPDATE calendar
SET subjects = array_remove(array_remove(subjects, 'espagnol'), 'analyse_doc')
WHERE subjects && ARRAY['espagnol', 'analyse_doc'];

-- 2. Pour les entrées qui n'ont plus aucune matière après retrait,
--    les remplacer par les matières faibles (enjeux, francais, maths)
UPDATE calendar
SET subjects = ARRAY['enjeux', 'francais', 'maths']
WHERE subjects = '{}' OR subjects IS NULL;

-- 3. Vérification
SELECT date, subjects, session_type FROM calendar
WHERE date >= '2026-03-26'
ORDER BY date;
