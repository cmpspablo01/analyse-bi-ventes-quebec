// =====================================================================
// 01_nettoyage_ventes.pq — Nettoyage de la table de faits (langage M)
// À coller dans Power BI : Accueil > Transformer les données >
// Nouvelle requête vide > Éditeur avancé.
//
// Ce que la requête corrige (défauts présents dans le CSV brut) :
//   1. Dates en deux formats mélangés (AAAA-MM-JJ et JJ/MM/AAAA)
//   2. Codes produits parfois en minuscules  -> normalisés en MAJUSCULES
//   3. Lignes dupliquées (même vente_id)     -> conservée : 1re occurrence
//   4. Types forcés (les CSV importent tout en texte par défaut)
//   5. Colonne calculée montant_ligne = quantite * prix
// Les retours (quantite < 0) sont CONSERVÉS et signalés par la colonne
// est_retour : un retour est une information d'affaires, pas une erreur.
// =====================================================================

let
    Source = Csv.Document(
        File.Contents("data/raw/ventes.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.None]
    ),
    Entetes = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    TypesTexte = Table.TransformColumnTypes(Entetes, {
        {"vente_id", Int64.Type}, {"magasin_id", Int64.Type},
        {"client_id", Int64.Type}, {"quantite", Int64.Type},
        {"prix_unitaire_facture", type number}
    }),

    // 1) Dates : on essaie le format ISO, sinon le format JJ/MM/AAAA
    DateNettoyee = Table.AddColumn(TypesTexte, "date_vente_propre", each
        let
            brut = Record.Field(_, "date_vente"),
            essaiIso = try Date.FromText(brut, [Format = "yyyy-MM-dd"]),
            essaiFr  = try Date.FromText(brut, [Format = "dd/MM/yyyy"])
        in
            if essaiIso[HasError] = false then essaiIso[Value]
            else if essaiFr[HasError] = false then essaiFr[Value]
            else null, type date),
    SansAncienneDate = Table.RemoveColumns(DateNettoyee, {"date_vente"}),
    DateRenommee = Table.RenameColumns(SansAncienneDate, {{"date_vente_propre", "date_vente"}}),

    // 2) Codes produits en majuscules
    CodesMaj = Table.TransformColumns(DateRenommee, {{"code_produit", Text.Upper, type text}}),

    // 3) Déduplication sur la clé d'affaires
    SansDoublons = Table.Distinct(CodesMaj, {"vente_id"}),

    // 5) Colonnes calculées
    AvecMontant = Table.AddColumn(SansDoublons, "montant_ligne",
        each [quantite] * [prix_unitaire_facture], type number),
    AvecFlagRetour = Table.AddColumn(AvecMontant, "est_retour",
        each [quantite] < 0, type logical),

    Resultat = Table.SelectColumns(AvecFlagRetour, {
        "vente_id", "date_vente", "magasin_id", "code_produit", "client_id",
        "canal", "quantite", "prix_unitaire_facture", "montant_ligne", "est_retour"
    })
in
    Resultat
