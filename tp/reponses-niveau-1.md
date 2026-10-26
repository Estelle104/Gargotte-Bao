# Réponses niveau 1

## 1.1 Base de données

1. Je choisis `date_jour` comme clé primaire de `plat_du_jour`. Une date ne peut apparaître qu'une fois dans la table, donc PostgreSQL garantit qu'il n'y a qu'un plat du jour par date.

2. Avec une colonne `est_plat_du_jour`, on ne pourrait pas facilement garder l'historique du plat proposé chaque jour. La base ne pourrait pas non plus garantir qu'il n'y a qu'un seul plat marqué pour une date, puisqu'il n'y aurait pas de date dans cette table.

La seconde exécution de la migration échoue parce que les colonnes, contraintes et table existent déjà. C'est normal pour ce script de migration, qui est prévu pour être exécuté une seule fois après le niveau 0.

3. Les messages exacts changent selon la version de PostgreSQL et les noms des contraintes. Pour un prix à zéro, la contrainte `ck_plat_prix` échoue. Pour un nom déjà utilisé, la contrainte `uq_plat_nom` échoue. Ce sont des erreurs de contrainte SQL, pas des messages de validation de l'API.

### 1.5 Plat du jour

4. La règle renvoie `409` parce que les données envoyées peuvent être valides, mais que l'opération est impossible dans l'état actuel : le plat est épuisé. `422` correspond plutôt à des données invalides.

5. Je retirerais le plat épuisé du plat du jour, ou je refuserais de le marquer épuisé tant qu'il est choisi pour aujourd'hui. Je préfère le retirer automatiquement afin que la carte ne recommande pas un plat que les clients ne peuvent pas commander.

### 1.7 Jeu de tests

6. Sans la vérification `is_not_unique`, la clé étrangère de PostgreSQL détecte que la catégorie 99 n'existe pas et renvoie une erreur SQL. Si le code ne la transforme pas en erreur de validation, l'API peut répondre `500`. La validation du modèle permet de renvoyer `422` avec une erreur claire sur `id_categorie`.

7. Désactiver le bouton dans Vue ne bloque pas une requête envoyée directement à l'API. Au niveau 1, si le service ne vérifie pas encore la disponibilité, on peut tenter par exemple :

```bash
curl -i -X POST http://localhost:8080/api/commandes \
  -H "Content-Type: application/json" \
  -d '{"numero_table":9,"lignes":[{"id_plat":7,"quantite":1}]}'
```

Si la requête est acceptée, le serveur n'applique pas encore la règle d'épuisement. Au niveau 2, cette règle doit aussi être vérifiée dans le service côté serveur.
