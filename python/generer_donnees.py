"""
Générateur de données reproductible — Détail Québec inc. (entreprise fictive)

Produit 4 fichiers CSV dans data/raw/ :
  - magasins.csv   (dimension)
  - produits.csv   (dimension)
  - clients.csv    (dimension)
  - ventes.csv     (faits : 1 ligne = 1 ligne de transaction)

Graine fixe (42) : les mêmes données sont régénérées à chaque exécution,
ce qui rend les résultats SQL / DAX / Power BI vérifiables par quiconque
clone le dépôt.

Défauts volontaires injectés dans ventes.csv (pour démontrer la qualité
des données et le nettoyage Power Query) :
  - quelques dates en format mélangé (AAAA-MM-JJ et JJ/MM/AAAA)
  - quelques quantités négatives (= retours, à traiter explicitement)
  - quelques lignes dupliquées et des codes produits en minuscules
"""

import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
SORTIE = Path(__file__).resolve().parent.parent / "data" / "raw"
SORTIE.mkdir(parents=True, exist_ok=True)

MAGASINS = [
    (1, "Montréal — Centre-ville", "Montréal", "Métropole"),
    (2, "Laval", "Laval", "Métropole"),
    (3, "Longueuil", "Longueuil", "Montérégie"),
    (4, "Châteauguay", "Châteauguay", "Montérégie"),
    (5, "Québec — Sainte-Foy", "Québec", "Capitale-Nationale"),
    (6, "Sherbrooke", "Sherbrooke", "Estrie"),
    (7, "Trois-Rivières", "Trois-Rivières", "Mauricie"),
    (8, "Gatineau", "Gatineau", "Outaouais"),
]

PRODUITS = [
    # (id, nom, catégorie, prix unitaire, coût unitaire)
    (101, "Chandail en coton", "Vêtements", 39.99, 18.50),
    (102, "Jean slim", "Vêtements", 69.99, 34.00),
    (103, "Manteau d'hiver", "Vêtements", 149.99, 82.00),
    (104, "Souliers de course", "Chaussures", 119.99, 61.00),
    (105, "Bottes d'hiver", "Chaussures", 139.99, 74.00),
    (106, "Casque d'écoute Bluetooth", "Électronique", 89.99, 47.00),
    (107, "Montre intelligente", "Électronique", 249.99, 155.00),
    (108, "Cafétière espresso", "Maison", 179.99, 102.00),
    (109, "Ensemble de casseroles", "Maison", 129.99, 68.00),
    (110, "Lampe de bureau DEL", "Maison", 49.99, 22.00),
    (111, "Sac à dos 25 L", "Accessoires", 59.99, 27.50),
    (112, "Lunettes de soleil", "Accessoires", 79.99, 31.00),
]

PRENOMS = ["Camille", "Liam", "Sofia", "Noah", "Emma", "Lucas", "Léa", "Nathan",
           "Chloé", "Hugo", "Aya", "Karim", "Priya", "Mateo", "Ines", "Olivier"]
NOMS = ["Tremblay", "Gagnon", "Roy", "Côté", "Bouchard", "Gauthier", "Morin",
        "Lacroix", "Fortin", "Nguyen", "Haddad", "Garcia", "Smith", "Pelletier"]


def ecrire_csv(nom, entetes, lignes):
    chemin = SORTIE / nom
    with chemin.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(entetes)
        w.writerows(lignes)
    print(f"{nom} : {len(lignes)} lignes")


def main():
    ecrire_csv("magasins.csv",
               ["magasin_id", "nom_magasin", "ville", "region"],
               MAGASINS)

    ecrire_csv("produits.csv",
               ["produit_id", "nom_produit", "categorie", "prix_unitaire", "cout_unitaire"],
               PRODUITS)

    clients = []
    for i in range(1, 401):
        nom = f"{random.choice(PRENOMS)} {random.choice(NOMS)}"
        ville = random.choice(MAGASINS)[2]
        segment = random.choices(["Régulier", "Fidèle", "Occasionnel"], weights=[5, 2, 3])[0]
        clients.append((1000 + i, nom, ville, segment))
    ecrire_csv("clients.csv",
               ["client_id", "nom_client", "ville", "segment"],
               clients)

    ventes = []
    debut = date(2023, 1, 1)
    vente_id = 1
    for jour in range(1096):  # 2023-01-01 → 2025-12-31
        d = debut + timedelta(days=jour)
        # saisonnalité simple : plus de ventes en fin de semaine et en décembre
        n = random.randint(4, 10)
        if d.weekday() >= 5:
            n += 4
        if d.month == 12:
            n += 5
        for _ in range(n):
            produit = random.choice(PRODUITS)
            qte = random.choices([1, 2, 3], weights=[7, 2, 1])[0]
            # ~3 % de retours (quantité négative)
            if random.random() < 0.03:
                qte = -qte
            date_txt = d.isoformat()
            # ~2 % de dates au format JJ/MM/AAAA (défaut volontaire)
            if random.random() < 0.02:
                date_txt = d.strftime("%d/%m/%Y")
            code = f"P{produit[0]}"
            # ~2 % de codes en minuscules (défaut volontaire)
            if random.random() < 0.02:
                code = code.lower()
            ventes.append((
                vente_id, date_txt, random.choice(MAGASINS)[0], code,
                random.choice(clients)[0],
                random.choices(["En magasin", "En ligne"], weights=[7, 3])[0],
                qte, produit[3],
            ))
            vente_id += 1

    # ~0,5 % de lignes dupliquées (défaut volontaire)
    ventes += random.sample(ventes, k=int(len(ventes) * 0.005))

    ecrire_csv("ventes.csv",
               ["vente_id", "date_vente", "magasin_id", "code_produit",
                "client_id", "canal", "quantite", "prix_unitaire_facture"],
               ventes)


if __name__ == "__main__":
    main()
