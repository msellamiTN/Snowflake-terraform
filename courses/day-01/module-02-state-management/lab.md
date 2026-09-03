# Lab M2 — State distant Azure Blob Storage

> [<- Jour 1](../README.md) · [<- Module precedent](../module-01-iac-workflow/lab.md) · **Module 2** · [Module suivant ->](../module-03-import-brownfield/lab.md)

| Élément | Valeur |
|---|---|
| **Durée** | 70 min |
| **Piste** | `[CORE]` |
| **Workspace** | `$HOME/Data2AI-Labs/data-platform` (le clone) |
| **Dossier de travail** | `labs/m02-state-management/` dans le clone |
| **Coût** | Aucun — Storage Account minimal |
| **Cleanup** | Conserver pour inspection — `Reset-Lab.ps1` nettoie au redémarrage |

> `[IMPORTANT]` Avant de commencer, vous devez etre dans la racine du clone
> et avoir execute `Learner-Login.ps1` dans **cette session** :
>
> ```powershell
> cd "$HOME\Data2AI-Labs\data-platform"
> .\scripts\Learner-Login.ps1 -LearnerPrefix APP01
> ```
>
> Cela set `TF_VAR_snowflake_token` (depuis `secrets/snowflake_pat.txt`)
> et les variables `ARM_*` pour Terraform.
>
> Ensuite, réinitialisez le lab pour partir d'un état propre :
>
> ```powershell
> .\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M02
> ```
>
> Avant `terraform plan`, verifiez que tout est pret :
>
> ```powershell
> cd labs\m02-state-management
> ..\..\scripts\Test-TerraformReady.ps1
> ```
>
> Si le pre-flight affiche `READY`, lancez `terraform plan -out "m02.tfplan"`.
> Sinon, suivez les corrections indiquees.

## 🎯 Mission

Votre state est actuellement local. En équipe, cela pose trois problèmes : pas de verrou, pas d'historique, pas de partage. Vous allez d'abord créer des ressources Snowflake avec un state local, puis migrer ce state vers Azure Blob Storage avec verrouillage natif.

## 🏗️ Architecture

```mermaid
flowchart LR
    A[State local<br/>terraform.tfstate] -->|terraform init -migrate-state| B[State distant<br/>Azure Blob Storage]
    B --> C[Lock Blob Lease]
    B --> D[Chiffrement au repos]
    B --> E[Isolation par clé]
```

## 🎯 Objectifs

- ✅ créer des ressources Snowflake avec un state local;
- ✅ créer un backend Azure Blob Storage pour le state Terraform;
- ✅ comprendre le paradoxe du bootstrapping;
- ✅ migrer un state local vers un backend distant;
- ✅ tester le verrouillage concurrent;
- ✅ analyser la structure du fichier `terraform.tfstate`;
- ✅ utiliser `terraform_remote_state` pour lire les outputs d'un autre projet.

## 📋 Prérequis

- [ ] Jour 0 terminé : `Toolchain status: READY`;
- [ ] `snow sql -q 'SELECT 1' -c training` réussit;
- [ ] Azure CLI installé;
- [ ] vous avez exécuté `Learner-Login` (le SP partagé a le rôle `Storage Blob Data Contributor` sur le Storage Account);
- [ ] `az account show --query 'name' -o tsv` affiche la souscription Azure;
- [ ] les variables Azure sont dans votre `.env` (`ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`, `ARM_RESOURCE_GROUP`, `ARM_STORAGE_ACCOUNT`, `ARM_CONTAINER`, `ARM_LOCATION`).

## � Partie 1 — Créer les ressources Snowflake (state local)

Ce lab est **autonome** : il ne dépend pas de M1. Vous allez créer vos propres ressources avec un préfixe `M02`, puis migrer leur state vers Azure Blob Storage.

### 📝 Étape 1.1 — Se placer dans le dossier du lab

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
cd "$HOME\Data2AI-Labs\data-platform\labs\m02-state-management"
Get-ChildItem -Force
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cd "$HOME/Data2AI-Labs/data-platform/labs/m02-state-management"
ls -la
```
</details>

✅ **Checkpoint** : `provider.tf`, `versions.tf`, `variables.tf`, `terraform.tfvars.example`, `main.tf` (stub), `outputs.tf` (stub), `.gitignore`.

### 📝 Étape 1.2 — Ajouter `warehouse_size` dans `variables.tf`

Le fichier `variables.tf` est pré-rempli avec les variables de base. **Ajoutez à la fin du fichier** :

```hcl
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

### 📝 Étape 1.3 — Créer `locals.tf`

```powershell
code locals.tf
```

```hcl
locals {
  database_name  = "${var.learner_prefix}_M02_RAW_${var.environment}"
  schema_name    = "INGESTION"
  warehouse_name = "WH_${var.learner_prefix}_M02_ETL_${var.environment}"
  common_comment = "Managed by Terraform | Training | ${var.learner_prefix}"
}
```

> 💡 **Note** : Le préfixe `M02` dans les noms isole ce lab des autres.

### 📝 Étape 1.4 — Créer `terraform.tfvars`

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
code terraform.tfvars
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cp terraform.tfvars.example terraform.tfvars
code terraform.tfvars
```
</details>

Ajoutez la ligne `warehouse_size` à la fin :

```hcl
snowflake_organization = "ZVFXOZW"
snowflake_account      = "PM71247"
snowflake_user         = "DATA2AI"
learner_prefix         = "APP01"
environment            = "DEV"
warehouse_size         = "X-SMALL"
```

Remplacez `APP01` par votre préfixe.

### 📝 Étape 1.5 — Créer `main.tf`

Remplacez le contenu du stub `main.tf` par :

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

### 📝 Étape 1.6 — Créer `outputs.tf`

Remplacez le contenu du stub `outputs.tf` par :

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

### 📝 Étape 1.7 — Initialiser, planifier, appliquer

```powershell
terraform fmt
terraform init
terraform validate
terraform plan -out "m02.tfplan"
terraform apply m02.tfplan
```

✅ **Checkpoint 1** :

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

Vérifiez que le state est local :

```powershell
terraform state list
```

✅ **Checkpoint** : 3 ressources listées. Le fichier `terraform.tfstate` est présent dans le dossier — c'est un **state local**.

> 🔒 **Security** : n'affichez jamais `ARM_CLIENT_SECRET`, `SNOWFLAKE_PASSWORD` ou `TF_VAR_snowflake_token`.

## 📝 Partie 2 — Créer le backend Azure (bootstrap)

Le backend Azure est créé manuellement avec Azure CLI, pas avec Terraform. C'est le paradoxe du bootstrapping : Terraform a besoin d'un backend pour stocker son state, mais ce backend ne peut pas être créé par Terraform lui-même.

### 📝 Étape 2.1 — Définir les variables

Les variables Azure ont été définies par `Learner-Login.ps1` (Windows) ou `learner-login.sh` (Linux/macOS).

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
Write-Host "Subscription: $env:ARM_SUBSCRIPTION_ID"
Write-Host "Resource Group: $env:ARM_RESOURCE_GROUP"
Write-Host "Storage Account: $env:ARM_STORAGE_ACCOUNT"
Write-Host "Container: $env:ARM_CONTAINER"
Write-Host "Location: $env:ARM_LOCATION"
```

> 💡 **Note** : Sous PowerShell, les variables d'environnement utilisent le préfixe `$env:`.
> Ne pas utiliser `source .env` ou `$ARM_SUBSCRIPTION_ID` sans `$env:`.
> Si une variable est vide, vérifiez que `.env` la contient et relancez `Learner-Login.ps1`.
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cd $HOME/Data2AI-Labs/data-platform
source .env 2>/dev/null || export $(grep -v '^#' .env | xargs)
echo "Subscription: $ARM_SUBSCRIPTION_ID"
echo "Resource Group: $ARM_RESOURCE_GROUP"
echo "Storage Account: $ARM_STORAGE_ACCOUNT"
echo "Container: $ARM_CONTAINER"
echo "Location: $ARM_LOCATION"
```
</details>

### 📝 Étape 2.2 — Créer le Resource Group

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
az group create `
    --name $env:ARM_RESOURCE_GROUP `
    --location $env:ARM_LOCATION `
    --output table
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
az group create \
    --name "$ARM_RESOURCE_GROUP" \
    --location "$ARM_LOCATION" \
    --output table
```
</details>

> 💡 **Note** : Si `ARM_LOCATION` n'est pas définie, utilisez une région disponible pour votre abonnement, par exemple `northeurope` ou `francecentral`.
> Certaines régions comme `westeurope` peuvent refuser de nouveaux clients.
> Pour lister les régions disponibles :
>
> ```powershell
> az account list-locations --query "[].name" -o table
> ```

✅ **Checkpoint** : une table avec `provisioningState : Succeeded`.

### 📝 Étape 2.3 — Créer le Storage Account

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
az storage account create `
    --name $env:ARM_STORAGE_ACCOUNT `
    --resource-group $env:ARM_RESOURCE_GROUP `
    --location $env:ARM_LOCATION `
    --sku "Standard_LRS" `
    --encryption-services blob `
    --output table
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
az storage account create \
    --name "$ARM_STORAGE_ACCOUNT" \
    --resource-group "$ARM_RESOURCE_GROUP" \
    --location "$ARM_LOCATION" \
    --sku "Standard_LRS" \
    --encryption-services blob \
    --output table
```
</details>

✅ **Checkpoint** : `provisioningState : Succeeded`.

> 💡 **Note** : Si le Storage Account existe déjà, Azure affiche `A storage account with the provided name is found. Will continue to update the existing account.` C'est normal : la commande est idempotente et conserve le compte existant.

> 💰 **COST** : `Standard_LRS` est le SKU le moins coûteux. Le state est petit; ce n'est pas une charge significative.

### 📝 Étape 2.4 — Créer le conteneur

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
az storage container create `
    --name $env:ARM_CONTAINER `
    --account-name $env:ARM_STORAGE_ACCOUNT `
    --auth-mode login `
    --output table
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
az storage container create \
    --name "$ARM_CONTAINER" \
    --account-name "$ARM_STORAGE_ACCOUNT" \
    --auth-mode login \
    --output table
```
</details>

✅ **Checkpoint** :

- `Created: True` : le conteneur vient d'être créé;
- `Created: False` : le conteneur existait déjà. C'est également un résultat valide.

> 💡 **Note** : La commande est idempotente. La relancer ne supprime ni le conteneur ni le state existant.

### 📝 Étape 2.5 — Vérifier

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
az storage account show `
    --name $env:ARM_STORAGE_ACCOUNT `
    --resource-group $env:ARM_RESOURCE_GROUP `
    --query "name" -o tsv
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
az storage account show \
    --name "$ARM_STORAGE_ACCOUNT" \
    --resource-group "$ARM_RESOURCE_GROUP" \
    --query "name" -o tsv
```
</details>

✅ **Checkpoint** : le nom du storage account.

## 📝 Partie 3 — Configurer le backend Terraform

> ⚠️ **IMPORTANT** : Choisissez **une seule méthode** :
>
> - **Méthode A — recommandée pour ce lab** : toutes les valeurs sont dans `backend.tf`; lancez ensuite `terraform init -migrate-state` **sans** `-backend-config`.
> - **Méthode B — optionnelle** : `backend.tf` contient un bloc vide et les valeurs sont dans `backend.hcl`; lancez alors `terraform init -migrate-state -backend-config="backend.hcl"`.
>
> Ne mélangez pas les deux méthodes.

### 📝 Étape 3.1 — Se placer dans le dossier du lab

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
cd "$HOME\Data2AI-Labs\data-platform\labs\m02-state-management"
Get-Location
Get-ChildItem backend.tf, terraform.tfstate -ErrorAction SilentlyContinue
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cd "$HOME/Data2AI-Labs/data-platform/labs/m02-state-management"
pwd
ls -l backend.tf terraform.tfstate 2>/dev/null
```
</details>

✅ **Checkpoint** : le répertoire courant se termine par `labs/m02-state-management` et le state local `terraform.tfstate` est présent avant la migration.

### 📝 Étape 3.2 — Méthode A recommandée : configurer `backend.tf`

Créez `backend.tf` :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
New-Item -ItemType File -Path backend.tf | Out-Null
code backend.tf
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
touch backend.tf
code backend.tf
```
</details>

Ajoutez exactement ce bloc, en adaptant les valeurs à votre `.env` si nécessaire :

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-data2ai-tf-state"
    storage_account_name = "sadata2aitfstatemsn"
    container_name       = "tfstate"
    key                  = "training/APP01/m02/terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

Remplacez `APP01` par votre préfixe apprenant. Vérifiez le fichier avant de continuer :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
Get-Content backend.tf
Test-Path backend.hcl
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cat backend.tf
test -f backend.hcl && echo "backend.hcl exists" || echo "backend.hcl absent"
```
</details>

✅ **Checkpoint** : `backend.tf` contient les quatre paramètres. Avec cette méthode, `backend.hcl` n'est pas nécessaire et peut être absent.

<details>
<summary>🧭 <b>Méthode B optionnelle : utiliser backend.hcl</b></summary>

Utilisez cette méthode uniquement si votre formateur la demande. Dans `backend.tf`, mettez seulement :

```hcl
terraform {
  backend "azurerm" {}
}
```

Créez ensuite `backend.hcl` dans le **même dossier** :

```hcl
resource_group_name  = "rg-data2ai-tf-state"
storage_account_name = "sadata2aitfstatemsn"
container_name       = "tfstate"
key                  = "training/APP01/m02/terraform.tfstate"
use_azuread_auth     = true
```

Vérifiez que le fichier existe avant l'initialisation :

```powershell
Test-Path backend.hcl
```

Le résultat doit être `True`. Pour cette méthode uniquement, la commande d'initialisation sera :

```powershell
terraform init -migrate-state -backend-config="backend.hcl"
```

> 🔒 **SECURITY** : `backend.hcl` est gitignored. Ne le commitez jamais.
</details>

### 📝 Étape 3.3 — Formater avant l'initialisation

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform fmt
terraform fmt -check
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform fmt
terraform fmt -check
```
</details>

✅ **Checkpoint** : les commandes se terminent sans erreur.

> 💡 **Note** : N'exécutez pas encore `terraform validate`. Après l'ajout ou la modification d'un backend, Terraform doit d'abord exécuter `terraform init`.

## 📝 Partie 4 — Migrer le state local vers Azure

### 📝 Étape 4.1 — Initialiser avec la méthode choisie

Pour la **méthode A recommandée**, exécutez uniquement :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform init -migrate-state
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform init -migrate-state
```
</details>

N'ajoutez pas `-backend-config=backend.hcl` lorsque les paramètres sont déjà écrits dans `backend.tf`.

Terraform détecte le changement de backend, demande confirmation, puis copie le state local vers Azure Blob Storage. Répondez `yes` si les noms du Resource Group, du Storage Account, du conteneur et de la clé sont corrects.

✅ **Checkpoint** :

```text
Successfully configured the backend "azurerm"!
Terraform has automatically migrated your state from "local" to "azurerm".
```

> 🔍 **En cas de `Too many command line arguments`** : vérifiez que vous êtes dans `labs/m02-state-management`. Si vous utilisez la méthode A, retirez complètement l'option `-backend-config` et relancez `terraform init -migrate-state`.

Validez ensuite la configuration initialisée :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform validate
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform validate
```
</details>

✅ **Checkpoint** : `Success! The configuration is valid.`

### 📝 Étape 4.2 — Inspecter les anciens fichiers de state local

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
Get-Item terraform.tfstate* -ErrorAction SilentlyContinue
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
ls terraform.tfstate* 2>/dev/null
```
</details>

> 💡 **Note** : Terraform peut conserver `terraform.tfstate` ou `terraform.tfstate.backup` comme copie locale après la migration. Leur présence ne signifie pas que Terraform les utilise encore. Ne les supprimez pas avant d'avoir validé le state distant aux étapes 4.3 et 4.4.

✅ **Checkpoint** : la migration s'est terminée sans erreur. La preuve définitive est obtenue avec `terraform state list` puis avec la présence du blob Azure.

### 📝 Étape 4.3 — Vérifier le state distant

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform state list
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform state list
```
</details>

✅ **Checkpoint** : les ressources M2 :

```text
snowflake_database.raw
snowflake_schema.ingestion
snowflake_warehouse.etl
```

### 📝 Étape 4.4 — Vérifier dans Azure

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
az storage blob list `
    --account-name $env:ARM_STORAGE_ACCOUNT `
    --container-name $env:ARM_CONTAINER `
    --auth-mode login `
    --query "[].name" -o tsv
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
az storage blob list \
    --account-name "$ARM_STORAGE_ACCOUNT" \
    --container-name "$ARM_CONTAINER" \
    --auth-mode login \
    --query "[].name" -o tsv
```
</details>

✅ **Checkpoint** : `training/APP01/m02/terraform.tfstate` (avec votre préfixe).

> 💡 **Note** : `--auth-mode login` force Azure CLI à utiliser la session ouverte par `Learner-Login.ps1`. Sans cette option, Azure CLI affiche un avertissement puis tente de récupérer une account key. Si la commande retourne `AuthorizationPermissionMismatch`, demandez au formateur d'attribuer au service principal le rôle `Storage Blob Data Reader` ou `Storage Blob Data Contributor`.

### 🌐 Étape 4.5 — Vérification Visuelle dans le Portail Microsoft Azure

Pour ancrer votre compréhension de l'infrastructure cloud :

1. Ouvrez votre navigateur sur **[portal.azure.com](https://portal.azure.com)**.
2. Recherchez le compte de stockage Azure indiqué par `$env:ARM_STORAGE_ACCOUNT`.
3. Dans le menu de gauche, cliquez sur **Conteneurs (Containers)** puis ouvrez le conteneur **`tfstate`**.
4. Naviguez dans le répertoire `training/APP01/m02/` :
   - Vous devez voir le fichier binaire `terraform.tfstate`.
   - Cliquez dessus et observez les métadonnées : **Chiffrement au repos (Microsoft-managed key)**, **Taille**, et **Statut du bail (*Lease status : Unlocked / Available*)**.
5. Cette inspection visuelle confirme que votre infrastructure d'équipe est prête pour la production.

---

## 📝 Partie 5 — Tester le verrouillage

### 📝 Étape 5.1 — Ouvrir et préparer deux terminaux

Chaque terminal possède ses propres variables d'environnement. Dans **les deux terminaux**, chargez donc l'authentification Azure, le PAT Snowflake et le bon dossier.

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01
cd .\labs\m02-state-management
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cd "$HOME/Data2AI-Labs/data-platform"
source ./scripts/learner-login.sh APP01
cd ./labs/m02-state-management
```
</details>

Remplacez `APP01` par votre préfixe.

### 📝 Étape 5.2 — Maintenir le verrou dans le terminal 1

Dans le terminal 1, lancez `terraform plan` **sans répondre à la confirmation** :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform plan
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform plan
```
</details>

Quand Terraform affiche `Enter a value:` ou commence à rafraîchir le state, laissez le terminal en attente. L'opération conserve alors le verrou du state.

> ⚠️ **IMPORTANT** : Ne saisissez pas `yes` et ne fermez pas le terminal. Ce test ne doit appliquer aucun changement.

### 📝 Étape 5.3 — Vérifier le verrou dans le terminal 2

Pendant que le terminal 1 attend toujours, exécutez dans le terminal 2 :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform plan -lock-timeout=0s
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform plan -lock-timeout=0s
```
</details>

✅ **Checkpoint** : Terraform refuse l'accès au state avec une erreur similaire à :

```text
Error: Error acquiring the state lock
```

C'est le comportement normal : le Blob Lease empêche les opérations concurrentes.

### 📝 Étape 5.4 — Libérer le verrou normalement

Retournez dans le terminal 1 et utilisez `Ctrl+C` pour annuler le plan. Attendez le retour du prompt, puis vérifiez dans le terminal 2 :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform plan
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform plan
```
</details>

✅ **Checkpoint** : le plan fonctionne de nouveau et affiche `No changes.`

> ⚠️ **SECURITY** : N'utilisez `terraform force-unlock <LOCK_ID>` que si le processus du terminal 1 est réellement arrêté et que le verrou reste présent. Forcer l'unlock pendant une opération active peut corrompre le state.

## 📝 Partie 6 — Analyser le state

### 📝 Étape 6.1 — Lister les ressources

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform state list
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform state list
```
</details>

### 📝 Étape 6.2 — Afficher le détail d'une ressource

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform state show snowflake_database.raw
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform state show snowflake_database.raw
```
</details>

### 📝 Étape 6.3 — Voir la structure JSON du state

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform show -json | Set-Content state.json
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform show -json > state.json
```
</details>

Le state contient :

| Champ | Rôle |
|---|---|
| `version` | Version du format de state |
| `terraform_version` | Version de Terraform qui a écrit le state |
| `serial` | Compteur incrémenté à chaque modification |
| `lineage` | Identifiant unique du state |
| `resources` | Liste des ressources gérées |

> 🔒 **SECURITY** : Le state peut contenir des données sensibles. Ne le commitez jamais. `state.json` est ignoré par Git.

## 📝 Partie 7 — terraform_remote_state

### 📝 Étape 7.1 — Créer un dossier reader

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
New-Item -ItemType Directory -Path labs\m02-state-management\reader -Force | Out-Null
cd labs\m02-state-management\reader
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cd "$HOME/Data2AI-Labs/data-platform"
mkdir -p labs/m02-state-management/reader
cd labs/m02-state-management/reader
```
</details>

### 📝 Étape 7.2 — Créer `main.tf`

```hcl
terraform {
  required_version = "= 1.14.5"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "= 2.14.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-data2ai-tf-state"
    storage_account_name = "sadata2aitfstatemsn"
    container_name       = "tfstate"
    key                  = "training/APP01/m02-reader/terraform.tfstate"
    use_azuread_auth     = true
  }
}

data "terraform_remote_state" "m02" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-data2ai-tf-state"
    storage_account_name = "sadata2aitfstatemsn"
    container_name       = "tfstate"
    key                  = "training/APP01/m02/terraform.tfstate"
    use_azuread_auth     = true
  }
}

output "raw_database_name" {
  value = data.terraform_remote_state.m02.outputs.database_name
}
```

### 📝 Étape 7.3 — Initialiser et appliquer

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform init
terraform apply -auto-approve
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform init
terraform apply -auto-approve
```
</details>

✅ **Checkpoint** : `raw_database_name` affiche le nom de la database créée dans ce lab (par exemple `APP01_M02_RAW_DEV`).

### 📝 Étape 7.4 — Nettoyer le dossier reader

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
Remove-Item -Recurse -Force labs\m02-state-management\reader
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cd "$HOME/Data2AI-Labs/data-platform"
rm -rf labs/m02-state-management/reader
```
</details>

---

## 🤖 Validation Automatisée de votre Progression

Exécutez le script d'évaluation pour valider la configuration du state distant Azure :

```powershell
.\scripts\SelfPacedLab.ps1 -Module 2 -All -Report
```

✅ **Résultat attendu :**
```text
[PASS] T1 backend.tf exists
[PASS] T1 backend "azurerm" declared
[PASS] T2 terraform init succeeded
[PASS] T3 Remote state migrated to Azure Blob
[PASS] T4 terraform fmt & validate
[PASS] T5 Locking configuration compliant
Result: 5/5 Tasks Passed.
```

---

## 🏆 Challenge

Ajoutez un output `state_metadata` dans `labs/m02-state-management/outputs.tf` qui expose :

```hcl
output "state_metadata" {
  value = {
    backend   = "azurerm"
    container = "tfstate"
    key       = "training/APP01/m02/terraform.tfstate"
  }
}
```

Critères :

- [ ] `terraform fmt -check` réussit;
- [ ] `terraform validate` réussit;
- [ ] `terraform output state_metadata` affiche les informations du backend;
- [ ] `terraform plan` reste sans changement;
- [ ] le blob `training/APP01/m02/terraform.tfstate` existe dans Azure (avec votre préfixe);
- [ ] Terraform utilise le backend distant après réouverture du terminal.

## 🧹 Cleanup

Conservez les ressources pour inspecter le state distant.

Pour repartir d'un état propre au début du lab, utilisez :

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M02
```

> ⚠️ **WARNING** : `Reset-Lab.ps1` détruit les ressources Snowflake et nettoie le state local. Le state distant dans Azure Blob Storage reste présent — vous pouvez le supprimer manuellement avec `az storage blob delete` si nécessaire.

---

## Navigation

[<- Lab M1](../module-01-iac-workflow/lab.md) · [<- Jour 1](../README.md) · **Lab M2** · [Lab M3 ->](../module-03-import-brownfield/lab.md)
