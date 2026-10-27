# Niveau 1 — La carte s’enrichit

## A. Base de données

### 1.1 Script de migration

1. Écrivez la table. Quelle colonne choisissez-vous comme clé primaire ? En quoi ce choix **garantit-il** la règle « un seul plat du jour par jour », sans aucune ligne de PHP ?

Je choisirai la colonne date_jour et id_plat comme cle primaire. Ce choix garantit la regle "un seul plat du jour pas jour ", sans aucune ligne de PHP car la date d'un jour ne se repetera jamais 2 fois, et aussi on a mis le id_plat pour que cette plat soit unique a cette date, donc ce plat et propre a ce jour, or le jour ne risque pas de se repeter 2 fois

2. Un camarade propose plutôt d’ajouter une colonne `est_plat_du_jour BOOLEAN` dans `plat`. Donnez **deux** informations ou garanties que l’on perdrait avec sa solution.


Si on ajoute est_plat_du_jour on risque de perdre la regle qu'un plat doit etre unique a une date specifique car il est possible qu'on a mis par accident true sur 2 plat , et on ne sait pas non plus a quelle date le plat est plat_du_jour et on ne peut pas non plus avoir l'historique du plat_du_jour

**Verification :** La seconde echoue et c'est normal, car au 2e fois, on a deja les contraintes cree avec leur noms specifique et on ne peut plus ajouter des contraintes avec le meme nom.


### 1.2 Données de test
3. Essayez d’insérer un plat à 0 Ar et un plat dont le nom existe déjà. Copiez les messages d’erreur de PostgreSQL dans vos réponses.

``` bash
 INSERT INTO plat (nom, prix, id_categorie, description) VALUES 
('Mofo gasy', 0, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Petite galette de riz cuite dans un moule spécial.');
ERROR:  new row for relation "plat" violates check constraint "chk_prix"
DETAIL:  Failing row contains (17, Mofo gasy, 0, 4, Petite galette de riz cuite dans un moule spécial., t).
gargote=> 
INSERT INTO plat (nom, prix, id_categorie, description) VALUES 
(NULL, 9, (SELECT id FROM categorie WHERE libelle = 'Goûter'), 'Petite galette de riz cuite dans un moule spécial.');
ERROR:  null value in column "nom" of relation "plat" violates not-null constraint
DETAIL:  Failing row contains (18, null, 9, 4, Petite galette de riz cuite dans un moule spécial., t).
gargote=> 

```

## B. API et code métier

### 1.3 Le modèle `PlatModel`
``` bash
 curl http://localhost:8080/api/plats/1
{
    "id": 1,
    "nom": "Vary amin'anana",
    "prix": 2000,
    "id_categorie": 1,
    "description": "Riz accompagné de feuilles vertes.",
    "disponible": true
}
```

### 1.4 Filtrer les plats disponibles

