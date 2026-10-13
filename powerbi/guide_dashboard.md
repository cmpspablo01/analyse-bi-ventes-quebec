# Guide du dashboard Power BI

Rapport : **Détail Québec inc. — Performance des ventes 2023-2025**
Fichier à produire : `rapport_detail_quebec.pbix` (non versionné — voir `.gitignore`)

## Modèle de données

- Schéma en étoile : `fait_ventes` au centre, relations 1-à-plusieurs vers
  `dim_date`, `dim_produit`, `dim_magasin`, `dim_client`
- Marquer `dim_date` comme **table de dates** (clé : `date_complete`)
- Masquer toutes les clés étrangères côté fait (les mesures seulement)
- Appliquer `theme.json` (Affichage > Thèmes > Parcourir)

## Page 1 — Vue exécutive

Objectif : la santé des ventes en 10 secondes.

- Cartes KPI : Ventes totales, Marge totale, % marge, Panier moyen,
  % retours — chacune avec sa variation YoY en info-bulle
- Courbe : Ventes par mois + moyenne mobile 3 mois (`mesures.dax`)
- Segments (slicers) : Année, Région, Canal
- Aucun tableau sur cette page : que des indicateurs et des tendances

## Page 2 — Magasins et régions

- Barres : Ventes par magasin, triées, avec le rang (`Rang magasin (ventes)`)
- Carte du Québec : bulles par ville, taille = ventes, couleur = % marge
- Matrice Région x Canal : ventes, panier moyen, % retours
- Drill-through vers la page 3 filtrée sur le magasin cliqué

## Page 3 — Produits

- Top 10 produits (barres) et poids de chaque catégorie (anneau)
- Nuage de points : prix unitaire (x) vs % marge (y), taille = ventes
- Tableau de détail par produit avec mise en forme conditionnelle sur le YoY

## Page 4 — Qualité des données

La page qui distingue un analyste BI d'un faiseur de graphiques.

- Compteurs issus de `sql/03_qualite_donnees.sql` : doublons supprimés,
  codes produits corrigés, dates reformatées, retours orphelins
- Nombre de lignes brutes vs lignes après nettoyage Power Query
- Note méthodologique : définitions des KPI et choix de traitement
  (les retours sont conservés et exclus des « ventes brutes »)

## Bonnes pratiques appliquées

- Mesures DAX centralisées dans une table `_Mesures`
- Aucune relation bidirectionnelle ; filtres à sens unique depuis les dimensions
- Titres de visuels = phrases de constat (« Les ventes de décembre dépassent
  novembre de 31 % »), pas des noms de champs
- Accessibilité : contraste du thème vérifié, texte alternatif sur les visuels clés
