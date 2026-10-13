// =====================================================================
// 02_table_calendrier.pq — Table de dates générée en M (langage M)
// Une table calendrier dédiée est indispensable pour le time
// intelligence en DAX (YTD, YoY, même période l'an passé).
// Plage : 2023-01-01 → 2025-12-31 (alignée sur les données de ventes)
// =====================================================================

let
    Debut = #date(2023, 1, 1),
    Fin = #date(2025, 12, 31),
    NbJours = Duration.Days(Fin - Debut) + 1,

    ListeDates = List.Dates(Debut, NbJours, #duration(1, 0, 0, 0)),
    TableDates = Table.FromList(ListeDates, Splitter.SplitByNothing(),
                     {"date_complete"}, null, ExtraValues.Error),

    Types = Table.TransformColumnTypes(TableDates, {{"date_complete", type date}}),

    AvecAnnees = Table.AddColumn(Types, "annee", each Date.Year([date_complete]), Int64.Type),
    AvecTrimestre = Table.AddColumn(AvecAnnees, "trimestre", each Date.QuarterOfYear([date_complete]), Int64.Type),
    AvecMois = Table.AddColumn(AvecTrimestre, "mois", each Date.Month([date_complete]), Int64.Type),
    AvecNomMois = Table.AddColumn(AvecMois, "nom_mois",
        each Date.MonthName([date_complete], "fr-CA"), type text),
    AvecJourSemaine = Table.AddColumn(AvecNomMois, "jour_semaine",
        each Date.DayOfWeekName([date_complete], "fr-CA"), type text),
    AvecFinSemaine = Table.AddColumn(AvecJourSemaine, "est_fin_semaine",
        each Date.DayOfWeek([date_complete], Day.Monday) >= 5, type logical),

    // Clé AAAAMMJJ, même format que dim_date côté SQL
    AvecCle = Table.AddColumn(AvecFinSemaine, "date_id", each
        [annee] * 10000 + [mois] * 100 + Date.Day([date_complete]), Int64.Type),

    Resultat = Table.SelectColumns(AvecCle, {
        "date_id", "date_complete", "annee", "trimestre", "mois",
        "nom_mois", "jour_semaine", "est_fin_semaine"
    })
in
    Resultat
