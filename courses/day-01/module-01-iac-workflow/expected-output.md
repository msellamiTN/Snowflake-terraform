# Résultats attendus — M1

> [<- Jour 1](../README.md) · [<- Jour 0](../../day-00/README.md) · **Module 1** · [Module suivant ->](../module-02-state-management/lab.md)

## Structure finale

```text
module-01-first-deployment/
├── .git/
├── .gitignore
├── .student-workspace.json
├── .terraform/
├── .terraform.lock.hcl
├── README.md
├── versions.tf
├── provider.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── terraform.tfvars.example
```

`m01.tfplan` et `m01.tfplan.json` peuvent exister localement mais ne doivent pas être commités.

## Validation Terraform

```text
Success! The configuration is valid.
```

## Premier plan

Les adresses attendues sont :

```text
snowflake_database.raw
snowflake_schema.ingestion
snowflake_warehouse.etl
```

Résumé :

```text
Plan: 3 to add, 0 to change, 0 to destroy.
```

Des attributs calculés et l’ordre d’affichage peuvent varier selon la version du provider.

## Apply

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

## State

```text
snowflake_database.raw
snowflake_schema.ingestion
snowflake_warehouse.etl
```

## Outputs

Les valeurs utilisent le préfixe de l’apprenant :

```text
database_name  = "ABC_RAW_DEV"
schema_name    = "INGESTION"
warehouse_name = "ABC_ETL_DEV"
```

## Preuve Snowflake

### Via CLI

- database `<PREFIX>_RAW_DEV` présente;
- schema `INGESTION` présent dans cette database;
- warehouse `<PREFIX>_ETL_DEV` présent, taille X-SMALL et suspendable automatiquement.

### Via interface web (https://app.snowflake.com)

Vérifiez visuellement dans Snowflake :

| Ressource | Section Snowflake | Screenshot |
|---|---|---|
| Database `<PREFIX>_RAW_DEV` | **Data > Databases** | ![Database](assets/lab_check_snowflake_db.png) |
| Schema `INGESTION` | **Data > Databases > <PREFIX>_RAW_DEV** | ![Schema](assets/lab_check_snowflake_schema.png) |
| Warehouse `WH_<PREFIX>_ETL_DEV` | **Admin > Warehouses** | ![Warehouse](assets/lab_check_snowflake_wh.png) |

## Idempotence

```text
No changes. Your infrastructure matches the configuration.
```

## Score du validateur

Les tâches 1 à 4 doivent être entièrement PASS avant `apply`. La tâche 5 vérifie la présence du plan JSON, exactement trois créations et aucune suppression sous PowerShell.
