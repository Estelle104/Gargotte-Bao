# Niveau 0 - Prise en main

## Lire le schema relationnel
1. Schema sql

categorie(**id**, libelle)

plat(**id**, nom, prix, #id_categorie)

commande(**id**, date_commande, numero_table)

commande_ligne (**id**, **#id_commande**, **id_plat**, quantite, prix_unitaire)

---

2. Pourquoi `commande_ligne` contient-elle une colonne `prix_unitaire`, alors que le prix est déjà dans `plat` ? Donnez un exemple concret où les deux valeurs seraient différentes.

`commande_ligne` contient `prix_unitaire` car ca permet d'enregistrer l'historique de prix d'un plat pour ce commande. Exmple si on fait juste reference au `prix` dans `plat` et le prix change par exemple demain via update et donc le calcul de montant gagné par ce commande avant cette modification serait tous fictif et faux 

--- 

3. Que se passe-t-il pour les lignes d’une commande quand on supprime la commande ? Quelle instruction en est responsable ?

Quand on supprime une commande, il faut utiliser `on delete cascade` pour aussi supprimer les `commande_ligne` de ce `commande` donc ce qui ont des relations avec ce commande qu'on veut supprimer

---

4. Repérez **trois données absurdes** que le schéma actuel accepte sans broncher (indice : essayez d’insérer à la main un prix négatif). Notez-les : vous les corrigerez au niveau 1 et 2.

- le `prix` dans `plat` peut etre negatif, ce qui n'est pas logique 
- dans commande, le `numero_table` ne doit pas etre not null car il est possible qu'un demande soit a emporter et donc, sans table
- le `numero_table` doit etre dans une autre table et seul le id doit etre dans `commande` via foreign-key car sinon, l'utilisateur risque d'entreer une valeur par exemple 999

## Interroger l’API à la main

a) liste des soupes
code http : 200

``` json
[
    {
        "id": 7,
        "nom": "Mi sao",
        "prix": 6500,
        "id_categorie": 2,
        "categorie": "Soupe"
    },
    {
        "id": 6,
        "nom": "Soupe chinoise",
        "prix": 6000,
        "id_categorie": 2,
        "categorie": "Soupe"
    }
]
```

b) creation d'un plat valide

code http : 201

``` json
{
    "id": 14,
    "nom": "Mofo gasy",
    "prix": 300,
    "id_categorie": 1
}
```

c) création d'un plat invalide
code http : 422

```json
{
    "message": "Données invalides.",
    "errors": {
        "nom": "Le nom du plat est obligatoire.",
        "prix": "Le prix doit être un nombre entier (en Ariary).",
        "id_categorie": "Choisissez une catégorie."
    }
}
```

d) suppression d'un plat présent dans une commande

code http : 409

```json
{
    "message": "Ce plat figure déjà dans des commandes, il ne peut pas être supprimé.",
    "errors": {}
}
```

e) une commande qui n'existe pas

code http : 404

```json
{
    "message": "Commande 999 introuvable.",
    "errors": {}
}
```

5. Pour **b** j'ai pas 200 car c'est une creation qui a reussi, mais non une requete en general

6. Pour **d**, C'est php qui bloque la suppression. 
``` php
            return $this->erreur('Ce plat figure déjà dans des commandes, il ne peut pas être supprimé.', 409);
```

7. Creation de commande avec curl
``` bash
curl -i -X POST http://localhost:8080/api/commandes \
  -H "Content-Type: application/json" \
  -d '{"numero_table":9,"lignes":[{"id_plat":4,"quantite":2},{"id_plat":10,"quantite":1}]}'

```

## 0.4 Suivre une requête de bout en bout

| # | Étape | Fichier | Fonction / ligne |
|---|---|---|---|
| 1 | Le formulaire est soumis | `components/PlatForm.vue` | |
| 2 | La requête HTTP est construite | | `requete()` |
| 3 | Vite transmet `/api/...` au port 8080 | | |
| 4 | CodeIgniter choisit le contrôleur | | |
| 5 | Le contrôleur lit le JSON | | |
| 6 | Les règles de validation sont vérifiées | | |
| 7 | La ligne est insérée | | |
| 8 | Le formulaire prévient l’écran parent | | `emit(…)` |
| 9 | L’écran recharge la liste | `views/CarteView.vue` | |

8. Où est le code métier de la création d’une commande ? Pourquoi n’est-il pas dans le contrôleur `Commandes.php` ?

c'est dans app/Services/ComamndeService.php. Ce n'est pas dans controller car il ne faut pas mettre du metier dans un controller mais un controller sert seulement de communication entre frontend et backend pas un endroit ou on implemente tout le metier

## 0.5 Repérer les notions de Vue
9. 
`Panier.vue` ne modifie jamais la quantité lui-même : il émet `plus` et `moins` parce que si une autre page utilise ce meme composant et si on modifie la quantite directement la bas, et autre page modifie aussi la quantite, on ne sait plus quelle page a modifie quoi? COmme ca on peut aussi reutiliser le composant 
C'est le `CommandeView.vue` qui modifie reellement la quantite

10. 
Le `watch` sert a recopier les valuers d'une variable quand on veut les modifier

Sans lui, quand on modifie un plat, les champs ne sont pas auto-remplie par les valeurs actuels 

## 0.6 Premières modifications

a) J'ai remplace "Chez Bao, Analakely" dans views/App.vue

b) 
```sql
INSERT INTO categorie (libelle) VALUES ('Goûter');
```

11. La catégorie apparaît dans la liste déroulante du formulaire sans que j'ai écrit de code car la liste deroulante affiche juste toutes les valeurs  recuperes de la base de donnee grace au code qui recupere une fois toutes les lignes de cette table 

