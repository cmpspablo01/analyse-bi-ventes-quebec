-- =====================================================================
-- 02_requetes_kpi.sql — Les requêtes derrière les KPI du dashboard
-- Démonstration : CTE, agrégations, fonctions fenêtres (LAG, RANK),
-- variation année sur année (YoY) et parts de marché internes.
-- =====================================================================

-- 1) Ventes et marge mensuelles, avec variation YoY (fonction fenêtre LAG)
WITH mensuel AS (
    SELECT
        d.annee,
        d.mois,
        SUM(f.montant_ligne)                                   AS ventes,
        SUM(f.quantite * (f.prix_unitaire_facture - p.cout_unitaire)) AS marge
    FROM dbo.fait_ventes f
    JOIN dbo.dim_date    d ON d.date_id = f.date_id
    JOIN dbo.dim_produit p ON p.produit_id = f.produit_id
    GROUP BY d.annee, d.mois
)
SELECT
    annee, mois, ventes, marge,
    ventes - LAG(ventes, 12) OVER (ORDER BY annee, mois) AS ecart_vs_meme_mois_an_passe,
    CAST(100.0 * (ventes - LAG(ventes, 12) OVER (ORDER BY annee, mois))
         / NULLIF(LAG(ventes, 12) OVER (ORDER BY annee, mois), 0) AS DECIMAL(6,2))
        AS pct_yoy
FROM mensuel
ORDER BY annee, mois;

-- 2) Top 5 des produits par catégorie (RANK dans une fenêtre partitionnée)
SELECT categorie, nom_produit, ventes, rang_dans_categorie
FROM (
    SELECT
        p.categorie,
        p.nom_produit,
        SUM(f.montant_ligne) AS ventes,
        RANK() OVER (PARTITION BY p.categorie ORDER BY SUM(f.montant_ligne) DESC) AS rang_dans_categorie
    FROM dbo.fait_ventes f
    JOIN dbo.dim_produit p ON p.produit_id = f.produit_id
    WHERE f.quantite > 0
    GROUP BY p.categorie, p.nom_produit
) t
WHERE rang_dans_categorie <= 5
ORDER BY categorie, rang_dans_categorie;

-- 3) Panier moyen et part des retours, par magasin et par canal
SELECT
    m.nom_magasin,
    f.canal,
    COUNT(DISTINCT f.vente_id)                                        AS nb_transactions,
    CAST(SUM(f.montant_ligne) / NULLIF(COUNT(DISTINCT f.vente_id), 0)
         AS DECIMAL(10,2))                                            AS panier_moyen,
    CAST(100.0 * SUM(CASE WHEN f.quantite < 0 THEN ABS(f.montant_ligne) ELSE 0 END)
         / NULLIF(SUM(CASE WHEN f.quantite > 0 THEN f.montant_ligne ELSE 0 END), 0)
         AS DECIMAL(5,2))                                            AS pct_retours_sur_ventes_brutes
FROM dbo.fait_ventes f
JOIN dbo.dim_magasin m ON m.magasin_id = f.magasin_id
GROUP BY m.nom_magasin, f.canal
ORDER BY m.nom_magasin, f.canal;

-- 4) Clients les plus fidèles : nombre de transactions et revenu généré
SELECT TOP (20)
    c.nom_client,
    c.segment,
    COUNT(*)              AS nb_lignes_achat,
    SUM(f.montant_ligne)  AS revenu_total
FROM dbo.fait_ventes f
JOIN dbo.dim_client c ON c.client_id = f.client_id
WHERE f.quantite > 0
GROUP BY c.nom_client, c.segment
ORDER BY revenu_total DESC;
