-- Ingrédients ; le stock initial sera ajouté par des mouvements ci-dessous.
INSERT INTO ingredient (nom, unite, stock, seuil_alerte) VALUES
    ('vary',       'kg',   0, 1.000),
    ('henakisoa',  'kg',   0, 1.000),
    ('ravitoto',   'kg',   0, 0.500),
    ('voanio',     'l',    0, 0.500),
    ('akoho',      'kg',   0, 0.500),
    ('tsaramaso',  'kg',   0, 0.500),
    ('anana',      'kg',   0, 0.300),
    ('mi',         'piece',0, 1.000),
    ('sakamalao',  'kg',   0, 0.100),
    ('sira',       'kg',   0, 0.100);

-- Une ligne par ingrédient des plats de la catégorie Plat ou Soupe.
INSERT INTO recette (id_plat, id_ingredient, quantite)
SELECT p.id, i.id, x.quantite
FROM (VALUES
    ('Vary amin''anana', 'vary', 0.150), ('Vary amin''anana', 'anana', 0.050), ('Vary amin''anana', 'sira', 0.002),
    ('Ravitoto sy henakisoa', 'ravitoto', 0.150), ('Ravitoto sy henakisoa', 'henakisoa', 0.120), ('Ravitoto sy henakisoa', 'sira', 0.002),
    ('Akoho sy voanio', 'akoho', 0.150), ('Akoho sy voanio', 'voanio', 0.100), ('Akoho sy voanio', 'vary', 0.150),
    ('Romazava', 'henakisoa', 0.100), ('Romazava', 'anana', 0.080), ('Romazava', 'vary', 0.150),
    ('Henakisoa sy tsaramaso', 'henakisoa', 0.100), ('Henakisoa sy tsaramaso', 'tsaramaso', 0.100), ('Henakisoa sy tsaramaso', 'vary', 0.150),
    ('Soupe chinoise', 'mi', 1.000), ('Soupe chinoise', 'akoho', 0.080), ('Soupe chinoise', 'anana', 0.030),
    ('Mi sao', 'mi', 1.000), ('Mi sao', 'akoho', 0.050), ('Mi sao', 'sakamalao', 0.003)
) AS x(nom_plat, nom_ingredient, quantite)
JOIN plat p ON p.nom = x.nom_plat
JOIN categorie c ON c.id = p.id_categorie AND c.libelle IN ('Plat', 'Soupe')
JOIN ingredient i ON i.nom = x.nom_ingredient;

-- Approvisionnements de départ. Le mi a été acheté puis perdu, il reste à zéro.
INSERT INTO mouvement_stock (id_ingredient, quantite, motif)
SELECT id, 0.500, 'approvisionnement' FROM ingredient WHERE nom = 'mi';
INSERT INTO mouvement_stock (id_ingredient, quantite, motif)
SELECT id, -0.500, 'perte' FROM ingredient WHERE nom = 'mi';

INSERT INTO mouvement_stock (id_ingredient, quantite, motif)
SELECT id, CASE nom
    WHEN 'vary' THEN 10.000
    WHEN 'henakisoa' THEN 0.200
    WHEN 'ravitoto' THEN 3.000
    WHEN 'voanio' THEN 2.000
    WHEN 'akoho' THEN 4.000
    WHEN 'tsaramaso' THEN 2.000
    WHEN 'anana' THEN 2.000
    WHEN 'sakamalao' THEN 1.000
    WHEN 'sira' THEN 1.000
END, 'approvisionnement'
FROM ingredient
WHERE nom <> 'mi';

UPDATE ingredient i
SET stock = COALESCE((
    SELECT SUM(m.quantite) FROM mouvement_stock m WHERE m.id_ingredient = i.id
), 0);
