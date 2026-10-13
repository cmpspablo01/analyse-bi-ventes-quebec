# Dictionnaire de données

## fait_ventes — une ligne = une ligne de transaction

| Colonne | Type | Définition | Règle de gestion |
|---|---|---|---|
| vente_id | int | Identifiant de la transaction | Unique après nettoyage ; les doublons du brut sont supprimés |
| date_vente | date | Date de la transaction | Deux formats présents dans le brut ; normalisée en Power Query |
| magasin_id | int | Magasin (clé étrangère) | Voir dim_magasin |
| code_produit | texte | Code catalogue, ex. `P101` | Normalisé en majuscules ; doit exister dans dim_produit |
| client_id | int | Client (clé étrangère) | Voir dim_client |
| canal | texte | `En magasin` ou `En ligne` | |
| quantite | int | Unités vendues | **Négatif = retour** ; conservé, jamais supprimé |
| prix_unitaire_facture | décimal | Prix réellement facturé | Comparé au prix catalogue dans les contrôles qualité |
| montant_ligne | décimal | `quantite * prix_unitaire_facture` | Colonne calculée ; négative pour un retour |

## Dimensions

- **dim_magasin** : 8 magasins, avec ville et région administrative
- **dim_produit** : 12 produits, 5 catégories, prix et coût unitaires (le coût sert au calcul de marge). Le CSV brut `produits.csv` porte `produit_id` (101 à 112) ; le `code_produit` de la dimension s'en déduit : `'P' + produit_id` (ex. 101 → `P101`), c'est par ce code que `fait_ventes` référence le produit, résolu vers `produit_id` au chargement
- **dim_client** : 400 clients fictifs, segmentés Régulier / Fidèle / Occasionnel
- **dim_date** : calendrier 2023-2025 généré en Power Query (M), clé `AAAAMMJJ`

## Définitions des KPI

| KPI | Définition exacte |
|---|---|
| Ventes totales | Somme de `montant_ligne`, retours inclus (donc nets) |
| Ventes brutes | Somme de `montant_ligne` des lignes avec `quantite > 0` |
| % retours | Montant absolu des retours / ventes brutes |
| Panier moyen | Ventes totales / nombre de transactions distinctes |
| Marge | `quantite * (prix facturé − coût unitaire du catalogue)` |
| Croissance YoY | (Période − même période l'an passé) / même période l'an passé |
