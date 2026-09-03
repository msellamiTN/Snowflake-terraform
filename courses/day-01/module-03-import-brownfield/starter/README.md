# Code de départ — M3 : Import & Brownfield

## Point de départ

M3 n'a pas de starter séparé. Vous travaillez sur le résultat de M2 dans `environments/dev/` :

- le state est distant (Azure Blob Storage avec `use_azuread_auth = true`);
- les ressources M1 sont gérées par Terraform (database, schemas, warehouse);
- `terraform plan` affiche `No changes`.

## Travail à réaliser pendant M3

Vous allez :

1. créer une database manuellement dans Snowflake (hors Terraform);
2. ajouter un bloc `resource` vide dans `main.tf`;
3. importer la ressource avec `terraform import`;
4. générer la configuration avec `terraform plan -generate-config-out`;
5. détecter et corriger une dérive;
6. refactorer avec un bloc `moved`.

Suivez les commandes et checkpoints du lab M3.
