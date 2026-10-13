# Analyse BI — Ventes au détail au Québec

Projet portfolio d'analyste en intelligence d'affaires (BI) : de la donnée brute
à la décision, avec **SQL**, **Power Query (M)**, **DAX** et **Power BI**.

> Cas d'étude : « Détail Québec inc. », une chaîne fictive de 8 magasins.
> Les données sont générées de façon reproductible par un script Python
> (graine fixe) — aucune donnée réelle ou confidentielle.

## Ce que ce projet démontre

| Compétence demandée en poste d'analyste BI | Où elle est démontrée |
|---|---|
| SQL (requêtes, CTE, fonctions fenêtres) | `sql/02_requetes_kpi.sql`, `sql/03_qualite_donnees.sql` |
| Modélisation en étoile (faits / dimensions) | `sql/01_schema_etoile.sql`, `docs/dictionnaire_donnees.md` |
| Power Query / langage M | `powerquery/*.pq` |
| DAX (mesures, time intelligence) | `powerbi/mesures.dax` |
| Power BI (rapports, KPI, navigation) | `powerbi/guide_dashboard.md`, `powerbi/theme.json` |
| Python pour préparer les données | `python/generer_donnees.py` |
| Qualité des données et documentation | `sql/03_qualite_donnees.sql`, `docs/` |

## Questions d'affaires auxquelles le dashboard répond

1. Comment évoluent les ventes et la marge par mois, par magasin et par région ?
2. Quels produits et catégories portent la croissance (et lesquels la tirent vers le bas) ?
3. Quel est le panier moyen, et comment varie-t-il selon le canal (en magasin / en ligne) ?
4. Quels clients sont les plus fidèles, et quelle part du revenu vient des retours ?
5. La qualité des données sources est-elle suffisante pour décider (doublons, valeurs nulles, retours sans vente) ?

## Structure du dépôt

```
data/raw/        Données brutes générées (CSV) : ventes, produits, magasins, clients
sql/             Schéma en étoile, requêtes KPI, contrôles de qualité
powerquery/      Scripts M de nettoyage et de transformation (étape ETL Power BI)
powerbi/         Mesures DAX, guide du dashboard, thème visuel
python/          Générateur de données reproductible
docs/            Dictionnaire de données, journal de bord du projet
```

## Démarrage rapide

```bash
python3 python/generer_donnees.py   # régénère les CSV dans data/raw/
```

Puis, dans Power BI Desktop :
1. Importer les CSV de `data/raw/`
2. Appliquer les requêtes de `powerquery/` dans l'éditeur Power Query
3. Créer les mesures de `powerbi/mesures.dax`
4. Suivre `powerbi/guide_dashboard.md` pour bâtir les 4 pages du rapport

## Auteur

Pablo Campos — Baccalauréat en informatique, Université de Montréal (2026)
Stage d'analyste de données / développeur au CSSDM (SQL, optimisation, qualité des données)
[LinkedIn](https://www.linkedin.com/in/pablo-cmps) · GitHub [@cmpspablo01](https://github.com/cmpspablo01)
