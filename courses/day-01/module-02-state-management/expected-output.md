# Résultat attendu — M2 : Gestion du State

## État local (avant migration)

```bash
cd environments/dev
terraform init
terraform plan
```

**Attendu :** Le plan réussit avec un état local. Les ressources M1 sont listées (database, schemas, warehouse).

## Configuration du backend Azure Blob

Après avoir construit `backend.tf` avec `use_azuread_auth = true` :

```bash
terraform init -migrate-state
```

**Attendu :**

```text
Successfully configured the backend "azurerm"!
Terraform has automatically migrated your state from "local" to "azurerm".
```

## Vérification du state dans Azure Blob

```bash
az storage blob list \
    --container-name tfstate \
    --account-name <storage_account> \
    --auth-mode login \
    --query "[].name" -o tsv
```

**Attendu :** Le blob `training/APP01/dev/terraform.tfstate` existe (avec votre préfixe).

## Plan post-migration

```bash
terraform state list
terraform plan
```

**Attendu :**

```text
snowflake_database.raw
snowflake_schema.raw["FINANCE"]
snowflake_schema.raw["SALES"]
snowflake_warehouse.etl
```

Puis :

```text
No changes. Your infrastructure matches the configuration.
```

## Test de verrouillage (Blob Lease)

```bash
# Terminal 1 :
terraform plan  # acquiert le lease

# Terminal 2 (simultanément) :
terraform plan -lock-timeout=0s  # doit échouer avec une erreur de verrou
```

**Attendu (terminal 2) :**

```text
Error: Error acquiring the state lock
```

Après `Ctrl+C` dans le terminal 1, le terminal 2 réussit :

```text
No changes. Your infrastructure matches the configuration.
```

## Récupération du state

```bash
terraform state pull
```

**Attendu :** Sortie JSON de l'état avec un tableau `resources` contenant les ressources M1.

## terraform_remote_state

```bash
cd environments/dev-reader
terraform init
terraform apply -auto-approve
terraform output raw_database_name
```

**Attendu :** Le nom de la database créée en M1 (par exemple `DB_RAW_DEV`).
