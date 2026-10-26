# Réponses niveau 2

## 2.1 Base de données

1. PostgreSQL refuse l'ajout direct. La table `commande` contient déjà des lignes, et leur nouvelle colonne `id_serveur` aurait la valeur `NULL`. Ça ne respecte donc pas `NOT NULL` ni la clé étrangère.

2. Je fais la migration en plusieurs étapes :

```sql
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
```

La contrainte de téléphone doit être adaptée si le format malgache validé par le projet exige un format précis.

La contrainte `ck_commande_paiement` signifie qu'une commande est payée si et seulement si elle a un mode et une date de paiement.

3. `UNIQUE (numero_table)` empêcherait de réutiliser une table même après que la commande est payée ou annulée. L'index unique partiel ne bloque que les statuts `en_cours` et `servie`.

4. La vérification PHP permet de renvoyer un message clair à Bao, par exemple le numéro de commande qui occupe la table. L'index PostgreSQL protège les données même si une requête concurrente ou un autre bout de code contourne la vérification PHP.

### 2.2 Données de test

5. Si le nombre de tables est écrit dans une contrainte SQL, il faut modifier le schéma à chaque ajout de table. Je préfère mettre cette règle dans `Config/Gargote.php`, qui fournit le nombre de tables au service et à l'interface depuis un seul endroit.

### 2.5 Prendre une commande

6. La contrainte `UNIQUE (id_commande, id_plat)` interdit deux lignes identiques pour le même plat dans une commande. Sans R4, on essaierait d'insérer deux lignes et la contrainte ferait échouer la commande. R4 additionne les quantités avant l'insertion et produit une seule ligne.

7. Vérifier R1 à R4 avant la transaction évite de commencer des écritures quand les données sont invalides. Ça garde la transaction courte et simplifie les erreurs renvoyées. Les vérifications qui peuvent changer en même temps que d'autres requêtes, comme la disponibilité de la table, doivent tout de même être protégées par la base et/ou vérifiées dans la transaction.

### 2.6 Faire avancer une commande

8. L'API fixe `date_paiement` au moment où elle reçoit et valide le paiement. Si l'interface envoyait cette date, elle pourrait être fausse ou modifiée par le client.

### 2.7 Listes et détail enrichis

9. L'interface affiche les transitions fournies par l'API. Si Bao ajoute `en_preparation`, les règles sont modifiées côté serveur et l'interface peut afficher la nouvelle transition sans recopier le cycle de vie dans Vue.

### 2.8 Jeu de tests

10. Sans R6, la requête atteint l'index unique partiel PostgreSQL. C'est donc la base qui bloque la deuxième commande. Si l'erreur de contrainte est traduite par l'API, le code attendu est `409` ; si elle n'est pas traitée, l'API risque de renvoyer `500`. R6 sert à répondre proprement avant d'arriver à cette erreur de base.

11. Sans `onUnmounted`, chaque fois qu'on revient sur l'écran, un nouveau minuteur continue de lancer des requêtes toutes les 30 secondes. Après trois changements d'onglet, il y a plusieurs minuteurs en parallèle. Avec `onUnmounted`, le minuteur de l'écran quitté est arrêté : il ne reste qu'une requête toutes les 30 secondes quand l'écran est ouvert, et aucune quand on l'a quitté. Le nombre exact dépend du moment où l'on compte et de la durée passée sur l'écran.
