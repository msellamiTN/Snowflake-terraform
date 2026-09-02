# Code de départ — M2 : gestion du state

## Point de départ

Ce starter reprend exactement le résultat du lab M1 avant la migration du state :

- database `APP01_RAW_DEV` (`snowflake_database.raw`) ;
- schema `INGESTION` (`snowflake_schema.ingestion`) ;
- warehouse `WH_APP01_ETL_DEV` (`snowflake_warehouse.etl`) ;
- outputs `database_name`, `schema_name` et `warehouse_name`.

`APP01` est un exemple : remplacez-le par le préfixe qui vous a été attribué dans `terraform.tfvars` et dans la clé du backend.

L'authentification Snowflake utilise exclusivement un PAT avec l'authenticator `PROGRAMMATIC_ACCESS_TOKEN`. La variable `snowflake_token` est sensible et doit être fournie via `TF_VAR_snowflake_token`. Ne placez aucun token dans les fichiers Terraform ou dans `terraform.tfvars`.

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
