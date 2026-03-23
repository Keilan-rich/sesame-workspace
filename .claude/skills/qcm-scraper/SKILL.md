---
name: qcm-scraper
description: |
  Parcourt automatiquement les 6 QCM de prepa.concours-sesame.net (Enjeux contemporains, Mathématiques, Compétences digitales, Français, Langues étrangères, Analyse documentaire), enregistre toutes les questions avec choix, bonne réponse et explication, puis compile tout dans un document Word dans sesame-prep/annales/QCM/.

  À utiliser quand l'utilisateur demande de "faire les QCM", "scraper les QCM", "récupérer les questions du site Sésame", "compléter les QCM en ligne", ou toute formulation similaire impliquant le site prepa.concours-sesame.net.
---

# QCM Scraper — prepa.concours-sesame.net

## Objectif

Naviguer sur les 6 QCM du site de préparation Sésame, répondre rapidement à toutes les questions (sans se soucier de la correction), et enregistrer : question, choix, bonne réponse, explication. Compiler le tout dans un document Word final.

---

## URLs des 6 sujets

| # | Matière | URL |
|---|---------|-----|
| 1 | Enjeux contemporains | https://prepa.concours-sesame.net/QCM-enjeux-contemporains |
| 2 | Mathématiques | https://prepa.concours-sesame.net/QCM-Mathematiques |
| 3 | Compétences digitales | https://prepa.concours-sesame.net/QCM-competences-digitales |
| 4 | Français | https://prepa.concours-sesame.net/QCM-francais |
| 5 | Langues étrangères | https://prepa.concours-sesame.net/QCM-langues-etrangeres |
| 6 | Analyse documentaire | https://prepa.concours-sesame.net/QCM-analyse-documentaire |

---

## Exécution

**Toujours utiliser le script Python** — ne pas naviguer manuellement dans le navigateur :

```bash
python tools/qcm-scraper.py
```

Le script gère l'auth, le scraping en parallèle (6 matières simultanées), et l'export `.docx` + `.json` automatiquement. Les credentials sont lus depuis `.env` (voir `.env.example`).

---

## Workflow par matière (référence — géré par le script)

Pour **chacun** des 6 sujets, dans l'ordre :

### 1. Naviguer et démarrer

- Aller à l'URL du sujet
- Prendre un screenshot pour voir la page
- Cliquer sur le bouton play/démarrer le quiz (souvent un triangle ▶ ou "Commencer")
- Prendre un screenshot pour confirmer que le quiz est lancé

### 2. Pour chaque question (10 questions par quiz)

1. **Screenshot immédiat** pour lire la question et les 4 choix
2. **Enregistrer** dans une variable temporaire :
   - Texte complet de la question
   - Les 4 choix (A, B, C, D)
3. **Cliquer n'importe quelle réponse** — vite, sans réfléchir à la correction
4. **Screenshot du résultat** — la page affiche en vert (bonne) ou rouge (mauvaise) avec "La bonne réponse était : X"
5. **Faire défiler vers le bas** pour voir l'explication complète
6. **Screenshot de l'explication**
7. **Enregistrer** :
   - La bonne réponse (indiquée clairement après validation)
   - L'explication complète
8. Cliquer **"Question suivante"** pour avancer

### 3. Fin du quiz

Après la question 10, la page de résultats apparaît. **Ne pas s'arrêter** — passer immédiatement au sujet suivant.

---

## Règles importantes

- **Vitesse avant tout** : répondre au hasard, ne pas perdre de temps à chercher la bonne réponse
- **Ne pas s'arrêter entre les matières** pour commenter ou résumer
- **Toujours scroller** après chaque réponse — l'explication et le bouton "Question suivante" peuvent être en bas de page
- **Le timer compte à rebours** mais on peut toujours répondre après expiration
- **Collecter TOUT** avant de compiler : ne compiler qu'une fois les 6 matières terminées
- Si certaines données ont **déjà été collectées** lors d'une session précédente (indiquées dans le message de l'utilisateur), les réutiliser directement — ne pas refaire ces quiz

---

## Structure des données à collecter

Pour chaque question, garder en mémoire :

```
MATIÈRE : [nom]
Q[n] : [texte de la question]
  A. [choix A]
  B. [choix B]
  C. [choix C]
  D. [choix D]
✅ Bonne réponse : [lettre + texte]
📝 Explication : [texte complet]
```

---

## Compilation finale (après TOUS les 6 sujets)

Une fois les 60 questions collectées (ou moins si certaines matières étaient déjà faites) :

### Lire le skill docx

Avant de créer le document, lire impérativement :
```
/sessions/bold-festive-cray/mnt/.skills/skills/docx/SKILL.md
```

### Créer le dossier de destination

Créer le dossier (s'il n'existe pas) :
```
/sessions/bold-festive-cray/mnt/Sésame Workspace/sesame-prep/annales/QCM/
```

### Nommer le fichier

Format : `QCM_Sesame_YYYY-MM-DD.docx` avec la date du jour.

### Structure du document Word

```
# QCM Sésame — [date]

## 1. Enjeux contemporains
[10 questions avec structure Q/choix/réponse/explication]

## 2. Mathématiques
[10 questions]

## 3. Compétences digitales
[10 questions]

## 4. Français
[10 questions]

## 5. Langues étrangères
[10 questions]

## 6. Analyse documentaire
[10 questions]
```

### Format de chaque question dans le document

```
**Q1. [Texte de la question]**

A. [choix A]
B. [choix B]
C. [choix C]
D. [choix D]

✅ **Bonne réponse : [lettre] — [texte du choix]**

> *Explication : [texte complet de l'explication]*

---
```

### Sauvegarder et partager

- Sauvegarder dans `/sessions/bold-festive-cray/mnt/Sésame Workspace/sesame-prep/annales/QCM/`
- Fournir un lien `computer://` pour que l'utilisateur puisse ouvrir le fichier directement

---

## Gestion des données partielles

Si l'utilisateur fournit des données déjà collectées pour certaines matières :
- Réutiliser ces données telles quelles
- Ne faire tourner que les matières manquantes
- Signaler clairement quelles matières viennent de la session en cours vs. les données fournies

---

## En cas de problème

- **Page ne charge pas** : réessayer une fois, puis noter la matière comme "non disponible" et continuer
- **Bouton introuvable** : prendre un screenshot et tenter un scroll ou un clic sur un élément visuellement similaire
- **Question mal capturée** : noter "[données partielles]" pour cette question plutôt que d'inventer
