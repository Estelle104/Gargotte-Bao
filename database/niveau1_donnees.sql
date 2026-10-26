-- Catégorie goûter : le script peut être relancé sans la dupliquer.
INSERT INTO categorie (libelle)
VALUES ('Goûter')
ON CONFLICT (libelle) DO NOTHING;

-- Quelques plats de goûter sans identifiants écrits en dur.
INSERT INTO plat (nom, prix, id_categorie, description)
SELECT x.nom, x.prix, c.id, x.description
FROM (VALUES
    ('Mofo gasy', 500, 'Petite galette de riz cuite dans un moule spécial.'),
    ('Mokary', 500, 'Galette de farine de riz et de lait de coco.'),
    ('Koba', 1000, 'Pâte de riz, arachide et banane cuite dans une feuille.'),
    ('Godrogodro', 800, 'Gâteau malgache parfumé à la cannelle.'),
    ('Menakely', 500, 'Beignet malgache croustillant.')
) AS x(nom, prix, description)
JOIN categorie c ON c.libelle = 'Goûter'
ON CONFLICT (nom) DO UPDATE
SET prix = EXCLUDED.prix,
    id_categorie = EXCLUDED.id_categorie,
    description = EXCLUDED.description;

-- Descriptions de plats déjà présents dans la carte.
UPDATE plat SET description = 'Riz accompagné de feuilles vertes.'
WHERE nom = 'Vary amin''anana';
UPDATE plat SET description = 'Feuilles de manioc pilées avec du porc.'
WHERE nom = 'Ravitoto sy henakisoa';
UPDATE plat SET description = 'Poulet préparé avec du lait de coco.'
WHERE nom = 'Akoho sy voanio';
UPDATE plat SET description = 'Bouillon malgache avec viande et brèdes.'
WHERE nom = 'Romazava';
UPDATE plat SET description = 'Porc servi avec des haricots.'
WHERE nom = 'Henakisoa sy tsaramaso';

-- Deux plats momentanément épuisés.
UPDATE plat SET disponible = FALSE WHERE nom IN ('Mi sao', 'Soupe chinoise');

-- Plat du jour pour les sept derniers jours, avec un plat disponible par date.
INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT jours.jour, choix.id
FROM generate_series(CURRENT_DATE - 6, CURRENT_DATE, INTERVAL '1 day') AS jours(jour)
CROSS JOIN LATERAL (
    SELECT p.id
    FROM plat p
    JOIN categorie c ON c.id = p.id_categorie
    WHERE c.libelle IN ('Plat', 'Soupe') AND p.disponible = TRUE
    ORDER BY random()
    LIMIT 1
) AS choix
ON CONFLICT (date_jour) DO UPDATE SET id_plat = EXCLUDED.id_plat;
