# Code de départ — M2 : gestion du state

## Point de départ

Ce starter reprend exactement le résultat du lab M1 :

- database `DB_RAW_DEV` (`snowflake_database.raw`) ;
- schemas `SALES` et `FINANCE` (`snowflake_schema.raw`) ;
- warehouse `WH_ETL_DEV` (`snowflake_warehouse.etl`) ;
- outputs `raw_database_name`, `etl_warehouse_name` et `schema_names`.

## Travail à réaliser pendant M2

`backend.tf` est volontairement neutralisé : aucun backend distant prêt à l'emploi n'est activé dans le starter. Pendant le lab, l'apprenant construit le bloc `backend "azurerm"`, configure l'authentification Microsoft Entra ID avec `use_azuread_auth = true`, puis migre le state local du M1.

`backend.tf.example` sert uniquement de référence pour les paramètres Azure actuels et la convention de clé canonique :

```text
training/APP01/dev/terraform.tfstate
```

Remplacez `APP01` par votre préfixe avant l'initialisation. Suivez ensuite les commandes et checkpoints du lab M2 pour effectuer la migration ; ne lancez pas `terraform init -migrate-state` tant que votre bloc backend n'est pas construit et vérifié.

## Versions

- Terraform `1.14.5`
- provider Snowflake `2.14.0`
