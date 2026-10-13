-- =====================================================================
-- 03_qualite_donnees.sql — Contrôles de qualité sur les données brutes
-- À exécuter AVANT de faire confiance à un KPI. Chaque requête retourne
-- le nombre de lignes problématiques ; l'objectif est 0 après nettoyage.
-- (Table source : dbo.brut_ventes, chargée telle quelle depuis le CSV)
-- =====================================================================

-- 1) Lignes dupliquées (même vente_id vu plus d'une fois)
SELECT COUNT(*) AS nb_doublons
FROM (
    SELECT vente_id
    FROM dbo.brut_ventes
    GROUP BY vente_id
    HAVING COUNT(*) > 1
) d;

-- 2) Valeurs manquantes sur les champs obligatoires
SELECT COUNT(*) AS nb_lignes_incompletes
FROM dbo.brut_ventes
WHERE date_vente IS NULL
   OR magasin_id IS NULL
   OR code_produit IS NULL
   OR quantite IS NULL;

-- 3) Codes produits qui ne correspondent à aucun produit du référentiel
--    (attrape aussi les codes en minuscules si la collation est sensible)
SELECT COUNT(*) AS nb_codes_inconnus
FROM dbo.brut_ventes b
LEFT JOIN dbo.dim_produit p
  ON p.code_produit = b.code_produit
WHERE p.produit_id IS NULL;

-- 4) Retours sans vente correspondante (même client, même produit)
SELECT COUNT(*) AS nb_retours_orphelins
FROM dbo.brut_ventes r
WHERE r.quantite < 0
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.brut_ventes v
      WHERE v.client_id = r.client_id
        AND v.code_produit = r.code_produit
        AND v.quantite > 0
  );

-- 5) Prix facturés qui diffèrent du prix catalogue (écarts à investiguer)
SELECT COUNT(*) AS nb_ecarts_prix
FROM dbo.brut_ventes b
JOIN dbo.dim_produit p
  ON p.code_produit = UPPER(b.code_produit)
WHERE b.prix_unitaire_facture <> p.prix_unitaire;
