# Journal de bord

Projet construit par étapes, un livrable vérifiable par commit —
la même discipline qu'un mandat BI réel : d'abord la donnée,
ensuite le modèle, puis seulement les visuels.

## Étapes

1. **Structure et README** — cadrage : questions d'affaires, compétences
   démontrées, arborescence du dépôt.
2. **Données** — générateur Python reproductible (graine fixe) :
   9 510 lignes de ventes 2023-2025, 8 magasins, 12 produits, 400 clients.
   Défauts volontaires injectés (dates mixtes, doublons, casse, retours)
   pour démontrer le nettoyage plutôt que le cacher.
3. **SQL** — schéma en étoile, requêtes KPI (CTE, `LAG` pour le YoY,
   `RANK` pour les tops par catégorie) et 5 contrôles de qualité.
4. **Power Query** — nettoyage en langage M : double format de date,
   déduplication sur clé d'affaires, normalisation des codes,
   colonne `est_retour` ; table calendrier générée en M.
5. **Power BI** — 14 mesures DAX (KPI, time intelligence, classements),
   guide du rapport en 4 pages dont une page « Qualité des données »,
   thème visuel.

## Prochaines étapes prévues

- [ ] Construire le fichier `.pbix` et ajouter des captures d'écran au README
- [ ] Ajouter une vue SQL `vue_ventes_mensuelles` et la brancher comme source unique du rapport
- [ ] Test de cohérence : total des ventes du dashboard = total de la requête SQL n°1
- [ ] Version anglaise du README (les recruteurs des firmes nationales travaillent souvent en EN)

## Choix techniques assumés

- **Données fictives et générées** : aucun enjeu de confidentialité, et
  quiconque clone le dépôt obtient exactement les mêmes résultats.
- **Retours conservés** (quantités négatives) : les exclure fausserait le
  panier moyen et cacherait un vrai indicateur d'affaires.
- **Pas de colonnes calculées DAX pour les agrégats** : mesures seulement,
  pour la performance du modèle.
