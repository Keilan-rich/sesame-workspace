---
name: actu-sesame
description: Mise à jour hebdomadaire des Enjeux contemporains. Fait une recherche web sur les 7 derniers jours, sélectionne 4-6 nouveaux événements à forte probabilité au concours, les injecte dans sesame-prep/enjeux-contemporains.html.
triggers:
  - /actu-sesame
  - "mise à jour enjeux"
  - "nouveaux événements"
  - "actu de la semaine"
---

# Skill : Actu Sésame — Mise à jour hebdomadaire Enjeux contemporains

## Ce que tu fais quand ce skill est invoqué

1. **Récupère la date du jour** depuis le contexte
2. **Fais 3 recherches web en parallèle** :
   - `actualité internationale semaine [date] géopolitique économie`
   - `France Europe institutions actualité [date] événement marquant`
   - `sport culture science technologie actualité [date]`
3. **Sélectionne 4 à 6 événements** selon les critères ci-dessous
4. **Lis** `sesame-prep/enjeux-contemporains.html` pour voir les événements déjà présents (array `EVENTS`)
5. **Injecte les nouveaux événements** dans le tableau JS `EVENTS` du fichier HTML
6. **Confirme à l'utilisateur** : "J'ai ajouté X nouveaux événements : [liste]."

---

## Critères de sélection — événements à forte probabilité au concours Sésame

### Retenir si :
- **Superlative ou record** : "premier", "plus grand", "record", "jamais vu"
- **Décision institutionnelle** : vote ONU, accord UE, loi majeure, sommet G7/G20/OTAN
- **Chiffre mémorable** : taux, montant, classement précis
- **Fait impliquant la France** directement (politique, économie, sport, culture)
- **Prix et récompenses** : Nobel, Goncourt, Palme d'or, Ballon d'Or, etc.
- **Événement géopolitique majeur** : cessez-le-feu, élection, renversement de régime
- **Avancée scientifique ou médicale** notable
- **Record sportif** ou champion mondial

### Écarter si :
- Événement purement national sans portée internationale
- Fait anecdotique sans chiffre précis ni conséquence
- Déjà couvert par une carte existante dans EVENTS
- Information non vérifiable ou spéculative

---

## Format des nouveaux événements à injecter

Chaque nouvel événement suit exactement ce format dans le tableau JS :

```js
{ id:'XX', domain:'[geo|eco|institutions|societe|sciences|tech|sport|culture]', date:'[Mois Année]',
  title:'Titre court (max 6 mots)',
  context:"Description en 2-3 phrases : qu'est-ce qui s'est passé, pourquoi c'est important, contexte.",
  facts:["Fait précis 1","Fait précis 2","Fait précis 3 (chiffre ou nom)"],
  question:"La question que Sésame pourrait poser sur cet événement ?" },
```

**IDs** : continuer la numérotation existante dans le domaine concerné (ex : si le dernier geo est g8 → prochain est g9).

---

## Couleurs par domaine (déjà dans le CSS)
- geo : #60a5fa (bleu)
- eco : #34d399 (vert)
- institutions : #a78bfa (violet)
- societe : #4ade80 (vert clair)
- sciences : #f472b6 (rose)
- tech : #06d6f5 (cyan)
- sport : #fb923c (orange)
- culture : #fbbf24 (amber)

---

## Où injecter dans le HTML

Dans `sesame-prep/enjeux-contemporains.html`, trouver la ligne :
```js
  { id:'c6', domain:'culture', ...}
];
```
Et ajouter les nouveaux événements **avant** le `];` fermant.

---

## Règles importantes
- Ne jamais supprimer d'événements existants
- Ne pas dupliquer un événement déjà présent
- Mettre à jour le total dans `hero-meta` : "XX événements"
- Confirmer à l'utilisateur en français avec la liste des titres ajoutés
- Dire : **"Ouvre `sesame-prep/enjeux-contemporains.html` pour voir les nouveaux événements."**
