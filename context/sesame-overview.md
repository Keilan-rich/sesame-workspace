# Sésame Workspace — Vue d'ensemble

*Dernière mise à jour : 2026-03-15*

---

## Qu'est-ce que c'est

Workspace de préparation au concours Sésame 2026 (écoles de commerce post-bac).
Le concours a lieu le **8 avril 2026** — soit 24 jours à partir du 15 mars.
L'objectif : maximiser le score sur 7 matières via des sessions interactives quotidiennes,
un suivi automatique de progression et un planning adaptatif.

---

## Objectifs actuels

- Suivre le planning 24 jours (calendar.md) : Phase 1 découverte → Phase 2 consolidation → Phase 3 sprint final
- Faire une session HTML chaque jour via `/daily-sesame`, enregistrer les scores
- Identifier et corriger les points faibles (Enjeux contemporains, Français, Espagnol)

---

## Format du concours Sésame

| Séquence | Matière | Questions | Temps |
|----------|---------|-----------|-------|
| S1 — Comprendre | Compétences digitales | 20 QCM | 20 min |
| S1 — Comprendre | Enjeux contemporains | 40 QCM | 30 min |
| S1 — Comprendre | Mathématiques | 20 ex. | 40 min |
| S2 — Communiquer | Français | 40 QCM | 30 min |
| S2 — Communiquer | Anglais | 40 QCM | 30 min |
| S2 — Communiquer | Espagnol | 40 QCM | 30 min |
| S3 — Analyser | Analyse documentaire | 20 QCM | 2h |

**Scoring :** Bonne réponse = points complets. Mauvaise ou absence = 0 (pas de malus).

---

## Stack technique

| Outil | Rôle |
|-------|------|
| Python | Serveur HTTP local (port 8765), gestion des sessions |
| HTML/CSS/JS | Sessions interactives (QCM, timer, scoring) |
| Markdown | Suivi de progression, planning, profil |
| JSON | Stockage des résultats de session |
| .bat / .pyw | Lancement Windows (serveur + navigateur) |

---

## Ressources disponibles

- **Livret d'entraînement Sésame 2025** (224 pages) — seule ressource officielle
  - Compétences digitales : p.17-22
  - Enjeux contemporains : p.23-36
  - Mathématiques : p.37-41+
  - Français : p.44-58
  - Anglais : p.60-68
  - Espagnol : p.96-103
  - Analyse documentaire : p.162-220+

---

## Contraintes

- Répondre toujours en français
- Le concours est dans moins d'un mois — prioriser l'efficacité sur l'exhaustivité
- Pas de malus au concours → encourager à répondre à toutes les questions
