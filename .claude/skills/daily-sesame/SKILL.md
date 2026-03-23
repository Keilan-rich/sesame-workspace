---
name: daily-sesame
description: Génère le plan de révision quotidien pour le Concours Sésame (8 avril 2026). Lit le profil, la progression, et produit un fichier HTML du jour avec des exercices concrets tirés des annales.
---

# Skill : Daily Sésame — Sésame 2026

## Ce que tu fais quand ce skill est invoqué

1. **Lis** `sesame-prep/question-bank.json` — mémoire des questions utilisées et sessions en cours (crée-le vide s'il n'existe pas : `{"questions":{},"sessions":{},"pending_session":null}`)
2. **Lis** `sesame-prep/profile.md` — format du concours, niveaux, temps dispo
3. **Lis** `sesame-prep/progress.md` — progression, difficultés identifiées
4. **Génère ou régénère les fichiers permanents** (voir section ci-dessous)
5. **Vérifie la dernière session quotidienne** dans `sessions/*.json` :
   - Si `"completed": true` → génère une nouvelle session avec de nouvelles questions
   - Si `"completed": false` (session interrompue) :
     - Lis le `pending_session` pour retrouver le fichier HTML d'hier et son SAVE_KEY (`sesame_pause_YYYY-MM-DD`)
     - Estime les questions restantes : `questions_totales - index_pause` (si `pending_session.questions_done` existe, sinon suppose 50%)
     - **Si questions restantes < 5** → considère comme quasi-complétée, génère une nouvelle session fraîche normalement
     - **Si questions restantes ≥ 5** → reprends les mêmes questions, date mise à jour, **et réutilise le même SAVE_KEY qu'hier** dans le nouveau HTML (pour que la reprise depuis la pause fonctionne). Dis : "Tu t'étais arrêté à la session du [date] (X questions restantes). Je la relance aujourd'hui — tu pourras reprendre où tu t'étais arrêté."
6. **Choisis les questions** uniquement parmi celles où `"used": false` dans la matière du jour — **et ne les marquer `"used": true` que quand la session est complétée**, pas à la génération
7. **Génère** `sesame-prep/daily/YYYY-MM-DD.html`
8. **Mets à jour** `question-bank.json` :
   - Marque les questions utilisées : `"used": true, "session": "YYYY-MM-DD"`
   - Ajoute l'entrée dans `"sessions"` avec `"completed": false`
   - Met `"pending_session": { "date": "YYYY-MM-DD", "subject": "...", "file": "..." }`
9. **Dis à l'utilisateur** d'ouvrir le fichier dans son navigateur

---

## Fichiers permanents — logique de régénération

À chaque invocation, applique cette règle pour `simulation.html` et `session-guidee.html` :

```
SI le fichier n'existe pas → générer
SINON SI la dernière entrée de ce type dans sessions/*.json a "completed": true → générer (nouvelle version)
SINON → ne rien faire, laisser le fichier existant intact
```

**Concrètement :** si l'utilisateur a fait la simulation mardi et lance /daily-sesame mercredi → nouvelle simulation générée. S'il ne l'a pas faite → même fichier conservé, il peut y retourner.

### `sesame-prep/simulation.html`
- **Contenu** : 60 questions chronométrées (10 par matière), accent `#6366f1` (indigo), label `⏱ Simulation concours`
- Pioche dans les questions `"used": false` de chaque matière
- Enregistre avec `"type":"simulation"` vers `http://localhost:8765/session`
- **Inclure pause/reprise** (même pattern que les daily : SAVE_KEY, saveState, resumeSession, bouton ✕ Quitter)

### `sesame-prep/session-guidee.html`
- **Contenu** : 2 matières les plus faibles selon `progress.md`, ~15 questions chacune, format mémo+retry (voir section Format spécial Dimanche)
- Accent `#f59e0b` (amber), label `☀️ Session guidée`
- Enregistre avec `"type":"session_guidee"`
- **Inclure pause/reprise** (même pattern)

---

### Quand marquer une session comme complétée
Quand l'utilisateur revient avec ses scores (ex: "j'ai eu 8/10") :
- Mets `"completed": true` et `"score": X` dans `sessions[date]`
- Mets `"pending_session": null` dans question-bank.json
- Met à jour `progress.md`

> Note : les sessions de type `"simulation"` et `"session_guidee"` sont aussi dans `sessions/*.json` avec leur champ `"completed"`. C'est ce champ que tu vérifies pour décider si `simulation.html` / `session-guidee.html` doit être régénéré au prochain `/daily-sesame`. Le serveur `localhost:8765` les sauvegarde automatiquement quand l'utilisateur termine la session dans le navigateur — tu n'as pas à les marquer manuellement sauf si l'utilisateur te le dit.

### Règle anti-répétition
- Ne jamais réutiliser une question déjà `"used": true`
- Si toutes les questions d'une matière sont `"used": true` → **NE PAS reset automatiquement**. Dire à l'utilisateur : "Tu as vu toutes les questions disponibles en [matière]. Fournis-moi de nouvelles questions pour continuer." Puis attendre.
- Si une matière a moins de questions que la session en demande, compléter avec des questions de révision (issues de `wrong_answers` des sessions passées)

---

## Sources de questions

### 1. QCM en ligne compilés (priorité)
`annales/QCM/QCM_Sesame_2026-03-15.docx` — questions issues de prepa.concours-sesame.net avec réponses et explications :
- Enjeux contemporains : 10 questions (ODD, PIB, OMC, Chine, géopolitique, IA, UE...)
- Mathématiques : 10 questions (dérivées, probabilités, suites, PGCD, Pythagore...)
- Compétences digitales : questions additionnelles (phishing, HTML, cookies...)

Utilise ces questions EN PRIORITÉ car elles viennent directement du site officiel et ont déjà une `explanation` rédigée.

### 2. Livret d'entraînement (source secondaire)

`annales/Livret-d-entrainement.pdf` — 1 exam complet 2025, 224 pages

| Sujet | Pages questions | Pages corrigés | Total questions |
|-------|----------------|----------------|----------------|
| Compétences digitales | p.17–21 | p.22 | 20q |
| Enjeux contemporains | p.23–35 | p.36 | 40q |
| Mathématiques | p.37–41 | p.42 | 20 exercices |
| Français | p.44–58 | p.59 | 40q |
| Anglais | p.60–68 | p.68 | 40q |
| Espagnol | p.96–103 | p.104 | 40q |
| Analyse documentaire | p.162–220 | p.220+ | 1 dossier |

---

## Format quotidien

| Contexte | Format |
|----------|--------|
| **Semaine** | **20 min total** · 2 matières · ~10 min chacune · environ 8-10 questions par matière |
| **Samedi** | Simulation d'une séquence complète (chrono réel) |
| **Dimanche** | **Session guidée ~40 min** · 2 matières les plus faibles · format spécial (voir ci-dessous) |

### Structure d'une session (ordre obligatoire)
1. **Révision des erreurs** — uniquement si `wrong_answers` existe dans les sessions JSON précédentes · 3-5 questions max · label "🔁 Révision"
2. **Matière 1** — ~10 questions nouvelles (~10 min)
3. **Matière 2** — ~10 questions nouvelles (~10 min)

> Si pas d'erreurs → on passe directement aux nouvelles questions sans bloc révision.

---

## Format spécial Dimanche — Session guidée

**Objectif :** progresser vraiment, pas juste s'entraîner.

**Sélection des matières :** lire `progress.md` → prendre les 2 matières avec le score moyen le plus bas.

**Structure (~40 min) :**
1. **Bloc 1 — Matière faible n°1** (~15 questions · ~20 min)
2. **Bloc 2 — Matière faible n°2** (~15 questions · ~20 min)

**Comportement question par question (à implémenter dans le HTML) :**

- Réponse correcte → feedback vert classique → question suivante
- Réponse incorrecte → **3 étapes** :
  1. Feedback rouge : `Incorrect — Bonne réponse : X. [texte] · [explanation]`
  2. **Encadré mémo** : extrait de la fiche mémo correspondant au thème de la question (2-4 lignes de rappel de cours, fond amber/jaune)
  3. **Bouton "Réessayer"** : repose la même question en mode retry (les options sont mélangées) — si correct au retry → vert + "Bien rattrapé ✓" · si faux à nouveau → passe à la suite avec compteur "à revoir"

**Dans le HTML du dimanche :**
- Couleur d'accent : `#f59e0b` (amber) pour signifier "session spéciale"
- Label : `☀️ Session guidée — Dimanche`
- Le score final distingue : score initial / score après retry / questions à revoir
- Les questions "ratées même au retry" sont ajoutées aux `wrong_answers` du JSON de session

**Données mémo à inclure dans chaque question :**
Ajouter un champ `memo` dans l'objet question :
```js
{ id:1, topic:"...", text:"...", options:[...], correct:"B",
  explanation:"...",
  memo:"Rappel : [2-4 lignes de cours sur ce thème tirées de la fiche mémo]" }
```

---

## Calendrier — consulte `sesame-prep/calendar.md` pour le détail complet

### Phase 1 — Découverte (15–26 mars) : couvrir toutes les matières
| Date | Session 1 | Session 2 |
|------|-----------|-----------|
| Lun 16 | Enjeux Q1-20 | Français Q1-20 |
| Mar 17 | Anglais Q1-20 | Espagnol Q1-20 |
| Mer 18 | Maths Ex1-10 | Digital Q11-20 |
| Jeu 19 | Enjeux Q21-40 | Français Q21-40 |
| Ven 20 | Anglais Q21-40 | Espagnol Q21-40 |
| **Sam 21** | **Simulation Séquence 1** (Digital+Enjeux+Maths, 1h30) | — |
| **Dim 22** | **Rattrapage** 2 matières les + faibles | — |
| Lun 23 | Maths Ex11-20 | Révision Enjeux (erreurs) |
| Mar 24 | Révision Français (erreurs) | Révision Anglais (erreurs) |
| Mer 25 | Révision Espagnol (erreurs) | Révision Digital (erreurs) |
| Jeu 26 | Analyse documentaire Q1-10 | — |

### Phase 2 — Consolidation (27 mars–3 avril) : corriger les faiblesses
- Simulations Séquence 2 (sam 28) et Séquence 3 (sam 4 avril)
- Re-tests sur questions ratées (données venant de `sessions/*.json`)

### Phase 3 — Sprint final (4–7 avril) : conditions réelles + repos
- Simulation complète · révision légère · aucun nouvel exercice J-1

---

## Adaptation dynamique

Avant de générer le plan, **lis `sesame-prep/sessions/*.json`** (dernières sessions) et `progress.md` :
- Si score < 50% sur une matière → augmente sa fréquence la semaine suivante
- Si score > 80% → peut passer en mode "maintenance" (1 session/semaine)
- En Phase 2 et 3 : les sessions "révision erreurs" doivent cibler les questions spécifiquement ratées (champ `wrong_answers` dans les fichiers JSON de session)

---

## Contenu de la session — Format exigé

Chaque session doit contenir dans cet ordre :
1. **Révision des erreurs** (si sessions précédentes existent dans `sessions/*.json`) : 3-5 questions issues des `wrong_answers` de la dernière session, affichées en mode quiz avant les nouvelles questions
2. **Bloc principal** : questions du jour tirées du livret (référence page précise)
3. **Objectif mesurable** : nombre de questions à faire, score visé
4. **Correction** : corrigés dans le même PDF

### Comment référencer les exercices du livret
- Compétences digitales : pages 17–22 (questions 1–20 + corrigés p.22)
- Enjeux contemporains : pages 23–36 (questions 1–40 + corrigés p.36)
- Mathématiques : pages 37+ (à explorer selon pagination)
- Français : dans Séquence 2
- Anglais : dans Séquence 2
- Espagnol : dans Séquence 2
- Analyse documentaire : Séquence 3

---

## Template HTML — FORMAT OBLIGATOIRE

Le fichier HTML généré DOIT utiliser le format interactif question-par-question. Pour trouver un fichier de référence à jour, liste `sesame-prep/daily/` et prends le plus récent. Ce template a :
- Un écran de démarrage (start screen) avec bouton "Reprendre" si état sauvegardé
- Un timer en haut
- Des points de navigation (dots)
- Les questions affichées UNE PAR UNE avec animation slide
- Un bouton "Suivant" qui apparaît après avoir répondu
- Un écran de résultats avec score ring et review
- Un toggle thème clair/sombre
- Un envoi automatique des résultats vers `http://localhost:8765/session`
- **Pause/reprise obligatoire** : bouton ⏸ (pause sur place) + bouton ✕ (quitter et sauvegarder), reprise via localStorage au retour. Pattern exact :
  - Le bouton ✕ redirige vers `'../hub.html'` (chemin relatif depuis `daily/`) — PAS `'hub.html'`
  - Le lien "← Retour" en haut pointe aussi vers `'../hub.html'`
  - `const SAVE_KEY = 'sesame_pause_YYYY-MM-DD'` (ou identifiant unique pour simulation/session-guidee)
  - `saveState()` après chaque réponse + `beforeunload`
  - `clearState()` dans `showResults()`
  - `checkSavedState()` au chargement → affiche bouton "Reprendre" avec indication Q X/N

**Structure du HTML à générer :**

1. Section "Révision erreurs" (si `sessions/*.json` existe) : charger les `wrong_answers` du dernier JSON via `localStorage.getItem('sesame_sessions')`, les afficher en 3-5 questions avant les questions du jour avec label "🔁 Révision — [matière]"
2. Puis les nouvelles questions du jour

**Structure des questions :**
Chaque question dans le tableau JS doit avoir :
```js
{ id:1, topic:"...", text:"...", options:["A","B","C","D"], correct:"B",
  explanation:"Explication courte pourquoi B est correct (1-2 phrases)" }
```
Le champ `explanation` est **obligatoire**. Il s'affiche dans le feedback quand l'utilisateur se trompe :
`Incorrect — Bonne réponse : B. [texte option B] · [explanation]`

**Couleurs par matière :**
- Compétences digitales : `#06d6f5`
- Enjeux contemporains : `#fbbf24`
- Mathématiques : `#34d399`
- Français : `#818cf8`
- Anglais : `#a78bfa`
- Espagnol : `#f87171`
- Analyse documentaire : `#fb923c`

**Ne pas utiliser l'ancien template checklist** — utiliser exclusivement le format quiz interactif.

---

## Important
- Les exercices doivent être **tirés du livret** avec références de page précises
- Les cases à cocher sont fonctionnelles dans le navigateur
- Termine toujours en disant : **"Ouvre `sesame-prep/daily/YYYY-MM-DD.html` dans ton navigateur. Quand tu as terminé, reviens me dire tes scores — je mets à jour progress.md automatiquement."**
- Si le fichier HTML existe déjà pour aujourd'hui, demande si tu dois le remplacer
- **Ne pas inclure de section "bilan à remplir" dans le HTML** — le suivi se fait en conversation avec Claude

---

## Enregistrement automatique des résultats

Quand l'utilisateur revient après une session et mentionne ses scores ou difficultés (ex: "j'ai eu 14/20", "j'étais nul en algos", "j'ai fini"), tu dois :

1. **Lire** `sesame-prep/progress.md`
2. **Mettre à jour** la section correspondante (date, matière, score, points faibles)
3. **Confirmer** à l'utilisateur : "Noté — j'ai mis à jour ton suivi."

### Ce que tu enregistres automatiquement
- Score obtenu (ex: 14/20)
- Thèmes/types de questions ratés (ex: "algorithmes", "formules tableur")
- Ressenti général si mentionné (ex: "trop facile", "galère")
- Date et matière

### Détection du retour de session
Déclenche la mise à jour si l'utilisateur dit des choses comme :
- "j'ai fini", "c'est fait", "j'ai terminé"
- "j'ai eu X/Y", "score : X", "X bonnes réponses"
- "j'étais nul en...", "j'ai raté les questions sur..."
- "c'était facile / difficile"
- ou simplement en revenant en conversation après avoir ouvert le plan du jour
