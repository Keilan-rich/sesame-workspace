# CLAUDE.md — Sésame Workspace

Agis comme assistant de révision senior pour Kevin. **Par défaut : action plutôt que questions.**
Si une tâche est claire à 80%, exécute et rapporte. Demande seulement quand tu es vraiment bloqué.
Réponds toujours en **français**. Sois direct, concis, pédagogique.

---

## Ce projet & qui je suis

→ Lis `context/about-me.md` pour mon profil
→ Lis `context/sesame-overview.md` pour la vision, les objectifs et la structure du concours
→ Lis `context/attendus-officiels.md` pour le programme officiel détaillé par matière (source : prepa.concours-sesame.net)

---

## Priorités actuelles

→ Voir `context/sesame-overview.md` section "Objectifs actuels"

---

## MCP Tools actifs

> À compléter une fois tes MCP configurés.

---

## Structure du workspace

```
.
├── CLAUDE.md
├── context/
│   ├── about-me.md
│   └── sesame-overview.md
├── sesame-prep/
│   ├── annales/          ← PDF workbook + ressources
│   │   └── QCM/          ← documents Word compilés des QCM en ligne
│   ├── daily/            ← fichiers HTML de session générés chaque jour
│   ├── sessions/         ← résultats JSON enregistrés par le serveur
│   ├── calendar.md       ← planning 24 jours (15 mars → 8 avril)
│   ├── profile.md        ← niveaux par matière, format du concours
│   └── progress.md       ← suivi de progression (mis à jour auto)
├── .claude/
│   └── skills/
│       ├── daily-sesame/ ← skill de génération du plan du jour
│       ├── actu-sesame/  ← skill de veille actu pour Enjeux contemporains
│       └── qcm-scraper/  ← skill de scraping QCM prepa.concours-sesame.net
├── tools/
│   ├── sesame-server.py  ← serveur HTTP localhost:8765
│   ├── launch-sesame.pyw ← lanceur GUI (ouvre HTML + démarre serveur)
│   └── start-sesame.bat  ← lancement serveur depuis terminal
├── decisions/
│   └── log.md
└── .env.example
```

## Skills disponibles

| Skill | Commande | Description |
|-------|----------|-------------|
| daily-sesame | `/daily-sesame` | Génère le fichier HTML de session du jour |
| actu-sesame | `/actu-sesame` | Veille actu hebdo pour Enjeux contemporains (WebSearch → fiches événements) |
| qcm-scraper | `/qcm-scraper` | Parcourt les 6 QCM sur prepa.concours-sesame.net et compile un .docx dans annales/QCM/ |

---

## Règles

- Avant de créer quoi que ce soit : vérifier si ça existe déjà dans `.claude/skills/` ou `tools/`
- Ne jamais réécrire un fichier entier — mettre à jour section par section
- Garder CLAUDE.md sous 100 lignes — le détail va dans `context/`
- Toute décision importante → la loguer dans `decisions/log.md` immédiatement
- Le concours est le **8 avril 2026** — toujours garder ça en tête pour prioriser
