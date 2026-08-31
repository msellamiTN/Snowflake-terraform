# Solution de référence — M1

La solution autonome et sans credential se trouve dans :

```text
student-track/module-01-first-deployment/solution/
```

## Ressources

| Adresse | Nom produit |
|---|---|
| `snowflake_database.raw` | `<PREFIX>_RAW_DEV` |
| `snowflake_schema.ingestion` | `INGESTION` |
| `snowflake_warehouse.etl` | `<PREFIX>_ETL_DEV` |

## Utilisation formateur

Copier la solution dans un dossier temporaire, jamais dans le workspace d’un apprenant bloqué. Créer localement `terraform.tfvars` depuis l’exemple, puis exécuter :

```text
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan
```

Le provider utilise le profil Snowflake CLI `terraform_svc`; aucun password, PAT ou chemin de clé n’est inclus.

## Différences avec l’ancien projet

- préfixe apprenant obligatoire;
- trois ressources seulement pour le premier apprentissage;
- profil CLI au lieu de credentials Terraform;
- aucune dépendance Azure;
- warehouse limité et initialement suspendu;
- solution séparée du starter.
