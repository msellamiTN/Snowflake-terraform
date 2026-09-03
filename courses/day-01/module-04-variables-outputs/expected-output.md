# Résultat attendu — M4 : Variables, Outputs & Lifecycle

> [<- Jour 1](../README.md) · [<- Module precedent](../module-03-import-brownfield/lab.md) · **Module 4** · [Jour 2 ->](../../day-02/README.md)

## Validation
```bash
cd project/01-day1-basics
terraform init -backend=false
terraform validate
```
**Attendu :** `Success! The configuration is valid.`

## Validation de variables
```bash
terraform plan -var="environment=INVALID"
```
**Attendu :** Message d'erreur : `environment must be one of: DEV, TEST, PROD.`

## Plan DEV
```bash
terraform plan -var-file=environments/dev.tfvars
```
**Attendu :** Ressources nommées avec le suffixe `_DEV` (ex. `DB_RAW_DEV`, `WH_ETL_DEV`).

## Plan TEST
```bash
terraform plan -var-file=environments/test.tfvars
```
**Attendu :** Ressources nommées avec le suffixe `_TEST` (ex. `DB_RAW_TEST`, `WH_ETL_TEST`).

## Outputs
```bash
terraform output
```
**Attendu :**
```
database_name = "DB_RAW_DEV"
warehouse_name = "WH_ETL_DEV"
schema_name = "INGESTION"
```

## Protection lifecycle
```bash
terraform destroy -var-file=environments/dev.tfvars
```
**Attendu :** Les blocs `prevent_destroy` bloquent la destruction (si configurés). Erreur : `Resource has prevent_destroy set to true.`

