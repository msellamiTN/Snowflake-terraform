# Lab M1 — Créer votre premier projet Terraform Snowflake

| Élément | Valeur |
|---|---|
| **Durée** | 3 heures |
| **Piste** | `[CORE]` |
| **Workspace** | `$HOME/Data2AI-Labs/data-platform` (le clone du Jour 0) |
| **Dossier de travail** | `environments/dev/` dans le clone |
| **Coût** | Warehouse X-SMALL, initialement suspendu |
| **Cleanup** | Conserver jusqu'au début du Jour 2 |

## Mission

Vous êtes Data Platform Engineer. Votre équipe vous demande une zone RAW minimale composée d'une database, d'un schema d'ingestion et d'un warehouse économique. Le changement doit être relisible avant exécution et reproductible sans exposer de credential.

## Architecture finale

```mermaid
flowchart LR
    DEV[Apprenant] --> TF[Terraform CLI]
    TF --> PROFILE[Connexion Snowflake CLI training]
    PROFILE --> SF[(Snowflake)]
    TF --> STATE[(State local)]
    SF --> DB[Database RAW]
    DB --> SCHEMA[Schema INGESTION]
    SF --> WH[Warehouse ETL suspendu]
```

## Objectifs

- créer une configuration Terraform depuis le clone du projet type;
- utiliser la connexion Snowflake CLI `training` sans placer de secret dans le code;
- expliquer les blocs `terraform`, `required_providers`, `provider` et `resource`;
- lire un plan avant application;
- prouver la création des trois ressources;
- vérifier l'idempotence avec un second plan.

## Prérequis

- [ ] Jour 0 terminé : `Toolchain status: READY`;
- [ ] `snow sql -q 'SELECT 1' -c training` réussit;
- [ ] le clone `data-platform-starter` existe sous `$HOME/Data2AI-Labs/data-platform`;
- [ ] vous connaissez votre préfixe unique (variable `LEARNER_PREFIX` dans `.env`).

## Partie 1 — Se placer dans le bon dossier

Tous les fichiers de M1 vont dans `environments/dev/` du clone.

```bash
cd $HOME/Data2AI-Labs/data-platform
cd environments/dev
```

Vérifiez que le dossier contient uniquement les fichiers d'exemple :

```bash
ls -la
```

**Attendu :** `README.md`, `backend.hcl.example`, `terraform.tfvars.example`. Aucun fichier `.tf`.

## Partie 2 — Déclarer Terraform et le provider

### Étape 2.1 — Créer `versions.tf`

**[WINDOWS]**

```powershell
New-Item -ItemType File -Path versions.tf
code versions.tf
```

**[UNIX]**

```bash
touch versions.tf
code versions.tf
```

Ajoutez :

```hcl
terraform {
  required_version = "= 1.14.5"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "= 2.14.0"
    }
  }
}
```

- `required_version` épingle exactement la version Terraform de la politique;
- `source` identifie le provider officiel;
- `= 2.14.0` épingle exactement la version du provider, sans accepter de correctif non testé.

> **Pourquoi pas `~> 2.14.0` ?** Voir [docs/version-policy.md](../../docs/version-policy.md). Une contrainte souple autorise des versions différentes entre apprenants.

### Étape 2.2 — Créer `provider.tf`

```hcl
provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  authenticator     = "PROGRAMMATIC_ACCESS_TOKEN"
  token             = var.snowflake_token
}
```

- `organization_name` et `account_name` identifient le compte Snowflake (lus depuis `.env`) ;
- `authenticator = "PROGRAMMATIC_ACCESS_TOKEN"` indique au provider d'utiliser le PAT ;
- `token` reçoit la valeur du PAT, passée via la variable `snowflake_token` (jamais en clair dans le code).

> **Sécurité** — Le PAT est lu depuis le fichier `secrets/snowflake_pat.txt` créé au Jour 0 et passé via `TF_VAR_snowflake_token`. Aucun secret n'est écrit dans un fichier `.tf`.

### Étape 2.3 — Formater et valider

```bash
terraform fmt
terraform init
terraform validate
```

**Attendu :** `The configuration is valid.`

## Partie 3 — Créer les variables et les noms

### Étape 3.1 — Créer `variables.tf`

```hcl
variable "snowflake_organization" {
  type        = string
  description = "Snowflake organization name (from .env)"
}

variable "snowflake_account" {
  type        = string
  description = "Snowflake account name (from .env)"
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake user name (from .env)"
}

variable "snowflake_token" {
  type        = string
  description = "Snowflake PAT (read from secrets/snowflake_pat.txt)"
  sensitive   = true
}

variable "learner_prefix" {
  type        = string
  description = "Unique uppercase prefix assigned to the learner"

  validation {
    condition     = can(regex("^[A-Z][A-Z0-9]{2,4}$", var.learner_prefix))
    error_message = "learner_prefix must contain 3-5 uppercase letters or digits."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "DEV"

  validation {
    condition     = contains(["DEV", "UAT", "PROD"], var.environment)
    error_message = "environment must be DEV, UAT or PROD."
  }
}

variable "warehouse_size" {
  type        = string
  description = "Training warehouse size"
  default     = "X-SMALL"

  validation {
    condition     = contains(["X-SMALL", "SMALL"], var.warehouse_size)
    error_message = "Training warehouses must be X-SMALL or SMALL."
  }
}
```

Les validations empêchent les noms non conformes et les warehouses trop grands pour ce lab.

### Étape 3.2 — Créer `locals.tf`

```hcl
locals {
  database_name  = "${var.learner_prefix}_RAW_${var.environment}"
  schema_name    = "INGESTION"
  warehouse_name = "WH_${var.learner_prefix}_ETL_${var.environment}"
  common_comment = "Managed by Terraform | Training | ${var.learner_prefix}"
}
```

### Étape 3.3 — Créer `terraform.tfvars`

```hcl
snowflake_organization = "ZVFXOZW"
snowflake_account      = "PM71247"
snowflake_user         = "DATA2AI"
learner_prefix         = "ABC"
environment            = "DEV"
warehouse_size         = "X-SMALL"
```

Remplacez `ABC` par votre préfixe (celui de votre `.env`). Adaptez les valeurs Snowflake à votre `.env` si nécessaire. Le fichier est ignoré par Git.

> **Note** — La variable `snowflake_token` (le PAT) n'est **pas** dans `terraform.tfvars`. Elle est passée via une variable d'environnement pour éviter de la stocker en clair (voir Étape 5.1).

### Étape 3.4 — Formater et valider

```bash
terraform fmt
terraform validate
```

**Attendu :** `The configuration is valid.`

## Partie 4 — Créer les ressources

### Étape 4.1 — Créer `main.tf`

```hcl
resource "snowflake_database" "raw" {
  name                        = local.database_name
  comment                     = local.common_comment
  data_retention_time_in_days = 1
}

resource "snowflake_schema" "ingestion" {
  database = snowflake_database.raw.name
  name     = local.schema_name
  comment  = local.common_comment
}

resource "snowflake_warehouse" "etl" {
  name                = local.warehouse_name
  comment             = local.common_comment
  warehouse_size      = var.warehouse_size
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
}
```

La référence `snowflake_database.raw.name` crée une dépendance implicite : Terraform doit créer la database avant son schema. Le warehouse est indépendant et peut être créé en parallèle.

### Étape 4.2 — Créer `outputs.tf`

```hcl
output "database_name" {
  value       = snowflake_database.raw.name
  description = "Database created by the learner"
}

output "schema_name" {
  value       = snowflake_schema.ingestion.name
  description = "Schema created inside the database"
}

output "warehouse_name" {
  value       = snowflake_warehouse.etl.name
  description = "Cost-controlled training warehouse"
}
```

### Étape 4.3 — Formater et valider

```bash
terraform fmt
terraform validate
```

**Attendu :** `The configuration is valid.`

## Partie 5 — Planifier sans modifier

### Étape 5.1 — Charger le PAT dans l'environnement

Le PAT ne doit pas être dans `terraform.tfvars`. On le charge depuis le fichier créé au Jour 0 :

**[WINDOWS]**

```powershell
$env:TF_VAR_snowflake_token = (Get-Content ..\..\secrets\snowflake_pat.txt -Raw).Trim()
```

**[UNIX]**

```bash
export TF_VAR_snowflake_token=$(cat ../../secrets/snowflake_pat.txt | tr -d '[:space:]')
```

> `[SECURITY]` La variable d'environnement `TF_VAR_snowflake_token` est automatiquement lue par Terraform. Elle n'apparaît ni dans le code, ni dans les logs, ni dans le state.

### Étape 5.2 — Planifier

```bash
terraform plan -out=m01.tfplan
```

Le plan attendu contient exactement :

- `snowflake_database.raw`;
- `snowflake_schema.ingestion`;
- `snowflake_warehouse.etl`.

Il doit afficher `3 to add`, aucune modification et aucune destruction.

> `[SECURITY]` Le plan contient des données de configuration. Il est ignoré par `*.tfplan`. Ne le commitez pas.

## Partie 6 — Appliquer après revue

Avant de continuer, relisez le plan et confirmez votre préfixe. L'application crée trois objets dans le compte Snowflake.

```bash
terraform apply m01.tfplan
```

**Attendu :**

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

## Partie 7 — Prouver le résultat

### Preuve Terraform

```bash
terraform output
terraform state list
```

### Preuve Snowflake

Remplacez `ABC` par votre préfixe :

```bash
snow sql -c training -q "SHOW DATABASES LIKE 'ABC_RAW_DEV'"
snow sql -c training -q "SHOW SCHEMAS LIKE 'INGESTION' IN DATABASE ABC_RAW_DEV"
snow sql -c training -q "SHOW WAREHOUSES LIKE 'WH_ABC_ETL_DEV'"
```

### Preuve d'idempotence

```bash
terraform plan
```

**Attendu :** `No changes. Your infrastructure matches the configuration.`

## Erreur contrôlée — Préfixe invalide

Dans `terraform.tfvars`, remplacez temporairement le préfixe par `abc-invalid`, puis exécutez :

```bash
terraform validate
terraform plan
```

Le plan doit refuser la valeur avec le message de validation. Restaurez ensuite votre préfixe majuscule et rejouez `terraform plan`.

Cette erreur ne modifie aucune ressource distante.

## Challenge

Ajoutez un output `resource_summary` contenant les trois noms dans un objet :

```hcl
output "resource_summary" {
  value = {
    database  = snowflake_database.raw.name
    schema    = snowflake_schema.ingestion.name
    warehouse = snowflake_warehouse.etl.name
  }
}
```

Critères :

- [ ] `terraform fmt -check` réussit;
- [ ] `terraform validate` réussit;
- [ ] `terraform output resource_summary` affiche vos trois noms;
- [ ] `terraform plan` reste sans changement;
- [ ] aucun credential n'est présent dans les fichiers `.tf` ou `.tfvars`.

## Point de reprise

Conservez le workspace et les ressources jusqu'au module State du Jour 2. Pour reprendre :

```bash
cd $HOME/Data2AI-Labs/data-platform/environments/dev
snow sql -q 'SELECT 1' -c training
terraform init
terraform plan
```

N'exécutez pas encore `terraform destroy` : le module suivant réutilise ces ressources pour expliquer le state, le drift et l'import.
