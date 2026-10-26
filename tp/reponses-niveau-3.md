# Reponses niveau 3

## 3.1 Base de donnees

1. La cle primaire de `recette` est (`id_plat`, `id_ingredient`). Un meme plat peut avoir plusieurs ingredients, mais un ingredient ne doit apparaître qu'une fois dans la recette du meme plat.

2. La contrainte peut etre ecrite comme ca:

```sql
CHECK (
    (motif IN ('commande', 'annulation') AND id_commande IS NOT NULL) OR
    (motif NOT IN ('commande', 'annulation') AND id_commande IS NULL)
)
```

3. Stocker `ingredient.stock` permet de le lire rapidement sans recalculer tous les mouvements. Le risque est que le stock enregistre ne correspond plus a la somme des mouvements si une mis a jour est oubliee ou echouee

```sql
SELECT i.id, i.nom, i.stock,
       COALESCE(SUM(m.quantite), 0) AS total_mouvements FROM ingredient i
LEFT JOIN mouvement_stock m ON m.id_ingredient = i.id
GROUP BY i.id, i.nom, i.stock HAVING i.stock <> COALESCE(SUM(m.quantite), 0);
```

### 3.2 Les vues SQL

4. Si un plat n'a pas de recette, l'API peut renvoyer `portions: null`. ca veut dire qu'aucune limite de stock n'est calculee pour ce plat.

### 3.3 Donnees de test

5. Les resultats dependent des donnees generees. Ces requetes permettent de verifier les repartitions après le chargement :

```sql
SELECT date_commande::date AS jour, COUNT(*) AS nb_commandes FROM commande WHERE statut = 'payee'
GROUP BY date_commande::date ORDER BY jour;
```

```sql
SELECT s.id AS id_serveur, s.nom, COUNT(*) AS nb_commandes
FROM commande c
JOIN serveur s ON s.id = c.id_serveur
WHERE c.statut = 'payee'
GROUP BY s.id, s.nom ORDER BY s.id;
```

```sql
SELECT mode_paiement, COUNT(*) AS nb_commandes
FROM commande
WHERE statut = 'payee'
GROUP BY mode_paiement
ORDER BY mode_paiement;
```

Les noms exacts des colonnes peuvent changer selon le schema du niveau 2. Il faut aussi coller les resultats obtenus après avoir lance les scripts.

## 3.4 Le service de stock

6. Il faut additionner le besoin en henakisoa des deux plats :

`2 × quantite de henakisoa dans la recette Ravitoto sy henakisoa + 1 × quantite de henakisoa dans la recette Henakisoa sy tsaramaso`.

Par exemple, si les recettes utilisent respectivement 0,12 kg et 0,10 kg, le besoin est `2 × 0,12 + 1 × 0,10 = 0,34 kg`. La methode `besoins()` doit donner le meme resultat, car elle additionne les ingredients communs des lignes. Il faut remplacer ces quantites par celles de mes recettes.

### 3.5 Stock et commandes

7. Les deux commandes peuvent etre enregistrees si le stock est verifie avant la transaction et que les verifications se font en meme temps. Les sorties mettent alors le stock a jour ; une contrainte `CHECK (stock >= 0)` empeche qu'il devienne negatif. Une des transactions echoue alors, et doit etre annulee entièrement.

8. Avec `SELECT ... FOR UPDATE`, on verrouille les lignes des ingredients necessaires dans la transaction. La seconde commande attend la fin de la première, puis relit le stock a jour. Comme il ne reste plus assez de henakisoa, elle est refusee.

### 3.6 Les routes du stock

9. `2,5` avec une virgule n'est pas un nombre decimal valide pour PHP. La validation doit repondre `422` avec une erreur indiquant que la quantite doit etre numerique et strictement positive.

### 3.7 Les statistiques

9. Je calcule le panier moyen en PHP a partir du chiffre d'affaires total et du nombre de commandes : `chiffre_affaires / nb_commandes`. Ce calcul est simple et les deux valeurs sont deja recuperees pour les statistiques. Il faut gerer le cas où il n'y a aucune commande pour eviter une division par zero.

## 3.10 Le tableau de bord

10. Le composant `Histogramme` recoit une fonction de formatage pour rester reutilisable. Il peut afficher des Ariary, un nombre de commandes ou d'autres valeurs sans connaître leur sens.

## 3.11 Le plan de salle

Je choisirais une route dediee qui renvoie les tables et leur commande ouverte, car le plan a besoin de ces informations ensemble pour afficher rapidement l'etat de chaque table.
