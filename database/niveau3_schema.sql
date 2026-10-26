-- Tables et contraintes du niveau 3 : stock, recettes et mouvements.
CREATE TABLE ingredient (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    unite VARCHAR(10) NOT NULL CHECK (unite IN ('kg', 'l', 'piece')),
    stock NUMERIC(10,3) NOT NULL DEFAULT 0 CHECK (stock >= 0),
    seuil_alerte NUMERIC(10,3) NOT NULL DEFAULT 0 CHECK (seuil_alerte >= 0)
);

CREATE TABLE recette (
    id_plat INTEGER NOT NULL REFERENCES plat(id) ON DELETE CASCADE,
    id_ingredient INTEGER NOT NULL REFERENCES ingredient(id),
    quantite NUMERIC(10,3) NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (id_plat, id_ingredient)
);

CREATE TABLE mouvement_stock (
    id SERIAL PRIMARY KEY,
    id_ingredient INTEGER NOT NULL REFERENCES ingredient(id),
    date_mouvement TIMESTAMP(0) NOT NULL DEFAULT now(),
    quantite NUMERIC(10,3) NOT NULL CHECK (quantite <> 0),
    motif VARCHAR(20) NOT NULL CHECK (motif IN ('approvisionnement', 'commande', 'annulation', 'perte')),
    id_commande INTEGER REFERENCES commande(id),
    CONSTRAINT ck_mouvement_commande CHECK (
        (motif IN ('commande', 'annulation') AND id_commande IS NOT NULL)
        OR (motif NOT IN ('commande', 'annulation') AND id_commande IS NULL)
    )
);

CREATE VIEW v_portions_possibles (id_plat, portions) AS
SELECT r.id_plat,
       MIN(FLOOR(i.stock / r.quantite))::INTEGER AS portions
FROM recette r
JOIN ingredient i ON i.id = r.id_ingredient
GROUP BY r.id_plat;

CREATE VIEW v_ventes_jour (jour, nb_commandes, chiffre_affaires) AS
SELECT c.date_commande::date,
       COUNT(DISTINCT c.id)::INTEGER,
       SUM(l.quantite * l.prix_unitaire)::BIGINT
FROM commande c
JOIN commande_ligne l ON l.id_commande = c.id
WHERE c.statut = 'payee'
GROUP BY c.date_commande::date;
