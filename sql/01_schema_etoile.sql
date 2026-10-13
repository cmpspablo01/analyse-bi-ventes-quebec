-- =====================================================================
-- 01_schema_etoile.sql — Modèle en étoile (SQL Server / T-SQL)
-- Fait :          fait_ventes (1 ligne = 1 ligne de transaction)
-- Dimensions :    dim_date, dim_produit, dim_magasin, dim_client
-- Objectif : un modèle simple, performant pour Power BI, où chaque
-- dimension se joint au fait par une clé unique (relation 1-à-plusieurs).
-- =====================================================================

CREATE TABLE dbo.dim_date (
    date_id        INT          NOT NULL PRIMARY KEY,   -- format AAAAMMJJ
    date_complete  DATE         NOT NULL,
    annee          SMALLINT     NOT NULL,
    trimestre      TINYINT      NOT NULL,
    mois           TINYINT      NOT NULL,
    nom_mois       NVARCHAR(15) NOT NULL,
    jour_semaine   NVARCHAR(10) NOT NULL,
    est_fin_semaine BIT         NOT NULL
);

CREATE TABLE dbo.dim_produit (
    produit_id     INT           NOT NULL PRIMARY KEY,
    code_produit   NVARCHAR(10)  NOT NULL UNIQUE,       -- ex. P101
    nom_produit    NVARCHAR(80)  NOT NULL,
    categorie      NVARCHAR(40)  NOT NULL,
    prix_unitaire  DECIMAL(10,2) NOT NULL,
    cout_unitaire  DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.dim_magasin (
    magasin_id   INT          NOT NULL PRIMARY KEY,
    nom_magasin  NVARCHAR(60) NOT NULL,
    ville        NVARCHAR(40) NOT NULL,
    region       NVARCHAR(40) NOT NULL
);

CREATE TABLE dbo.dim_client (
    client_id   INT          NOT NULL PRIMARY KEY,
    nom_client  NVARCHAR(80) NOT NULL,
    ville       NVARCHAR(40) NOT NULL,
    segment     NVARCHAR(20) NOT NULL   -- Régulier / Fidèle / Occasionnel
);

CREATE TABLE dbo.fait_ventes (
    vente_id              INT           NOT NULL PRIMARY KEY,
    date_id               INT           NOT NULL REFERENCES dbo.dim_date(date_id),
    produit_id            INT           NOT NULL REFERENCES dbo.dim_produit(produit_id),
    magasin_id            INT           NOT NULL REFERENCES dbo.dim_magasin(magasin_id),
    client_id             INT           NOT NULL REFERENCES dbo.dim_client(client_id),
    canal                 NVARCHAR(15)  NOT NULL,  -- En magasin / En ligne
    quantite              INT           NOT NULL,  -- négatif = retour
    prix_unitaire_facture DECIMAL(10,2) NOT NULL,
    montant_ligne         AS (quantite * prix_unitaire_facture) PERSISTED
);

CREATE INDEX IX_fait_ventes_date    ON dbo.fait_ventes(date_id);
CREATE INDEX IX_fait_ventes_produit ON dbo.fait_ventes(produit_id);
CREATE INDEX IX_fait_ventes_magasin ON dbo.fait_ventes(magasin_id);
