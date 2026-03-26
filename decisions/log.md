# Décisions — Log

## 2026-03-26 — Désactivation temporaire d'Espagnol et Analyse documentaire

**Contexte :** Pas de questions d'entraînement disponibles pour ces 2 matières.
**Décision :** Filtre temporaire côté code uniquement — `DISABLED_SUBJECTS` dans `sesame-app/api/cron/generate-daily.js`.
**Ce qui n'est PAS modifié :** la table `calendar` Supabase et les fichiers locaux (`calendar.md`, `profile.md`) restent intacts.
**Pour réactiver :** retirer la matière du tableau `DISABLED_SUBJECTS` dans `generate-daily.js`.
