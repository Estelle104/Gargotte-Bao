-- Migration du niveau 2 : serveurs et cycle de vie des commandes.
CREATE TABLE serveur (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    telephone VARCHAR(30) NOT NULL UNIQUE,
    actif BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO serveur (nom, telephone, actif)
VALUES ('Bao (historique)', '0340000000', TRUE);

ALTER TABLE commande ADD COLUMN id_serveur INTEGER REFERENCES serveur(id);
UPDATE commande
SET id_serveur = (SELECT id FROM serveur WHERE nom = 'Bao (historique)');
ALTER TABLE commande ALTER COLUMN id_serveur SET NOT NULL;

ALTER TABLE commande
    ADD COLUMN statut VARCHAR(20) NOT NULL DEFAULT 'en_cours',
    ADD COLUMN mode_paiement VARCHAR(30),
    ADD COLUMN date_paiement TIMESTAMP(0);

ALTER TABLE commande ADD CONSTRAINT ck_commande_statut
    CHECK (statut IN ('en_cours', 'servie', 'payee', 'annulee'));
ALTER TABLE commande ADD CONSTRAINT ck_commande_mode_paiement
    CHECK (mode_paiement IS NULL OR mode_paiement IN ('especes', 'mvola', 'orange_money', 'airtel_money'));
ALTER TABLE commande ADD CONSTRAINT ck_commande_paiement CHECK (
    (statut = 'payee') = (mode_paiement IS NOT NULL AND date_paiement IS NOT NULL)
);

ALTER TABLE commande_ligne
    ADD CONSTRAINT ck_commande_ligne_quantite CHECK (quantite > 0),
    ADD CONSTRAINT uq_commande_ligne_plat UNIQUE (id_commande, id_plat);

CREATE UNIQUE INDEX ux_commande_table_ouverte
    ON commande (numero_table)
    WHERE statut IN ('en_cours', 'servie');
