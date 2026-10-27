-- inserer gouter dabs categirie
INSERT INTO categorie (libelle)
VALUES ('Goûter')
ON CONFLICT (libelle) DO NOTHING;

-- Quelques plats de goûter.
INSERT INTO plat (nom, prix, id_categorie, description) VALUES 
('Mofo gasy', 500, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Petite galette de riz cuite dans un moule spécial.'),
('Mokary', 500, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Galette de farine de riz et de lait de coco.'),
('Koba', 1000, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Pâte de riz, arachide et banane cuite dans une feuille.'),
('Godrogodro', 800, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Gâteau malgache parfumé à la cannelle.'),
('Menakely', 500, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Beignet malgache croustillant.');

-- ajout desc au plat
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

-- marquer certains plats comme non disponibles
UPDATE plat SET disponible = FALSE WHERE nom IN ('Mi sao', 'Soupe chinoise');

-- Plat du jour pour les 6 derniers jours, avec un plat disponible par date.
INSERT INTO plat_du_jour (date_jour, id_plat) VALUES
(CURRENT_DATE - INTERVAL '6 days', (SELECT id FROM plat WHERE nom = 'Vary amin''anana')),
(CURRENT_DATE - INTERVAL '5 days', (SELECT id FROM plat WHERE nom = 'Ravitoto sy henakisoa')),
(CURRENT_DATE - INTERVAL '4 days', (SELECT id FROM plat WHERE nom = 'Akoho sy voanio')),
(CURRENT_DATE - INTERVAL '3 days', (SELECT id FROM plat WHERE nom = 'Romazava')),
(CURRENT_DATE -INTERVAL '2 days', (SELECT id FROM plat WHERE nom = 'Henakisoa sy tsaramaso')),
(CURRENT_DATE - INTERVAL '1 day', (SELECT id FROM plat WHERE nom = 'Mi sao')),
(CURRENT_DATE, (SELECT id FROM plat WHERE nom = 'Soupe chinoise'));

-- INsertion plat
INSERT INTO plat (nom, prix, id_categorie, description) VALUES 
('Mofo gasy', 0, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Petite galette de riz cuite dans un moule spécial.');

INSERT INTO plat (nom, prix, id_categorie, description) VALUES 
(NULL, 9, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Petite galette de riz cuite dans un moule spécial.');
