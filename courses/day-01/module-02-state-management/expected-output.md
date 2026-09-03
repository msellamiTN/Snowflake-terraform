# Résultat attendu — M2 : Gestion du State

## État local (avant migration)
```bash
cd project/02-day1-state
terraform init
terraform plan
```
**Attendu :** Le plan réussit avec un état local. Nombre de ressources : identique à M1 (3 ressources).

## Configuration du backend Azure Blob
Après avoir décommenté `backend.tf` :
```bash
terraform init -migrate-state
```
**Attendu :**
```
Successfully configured the backend "azurerm"! Terraform will automatically use this backend unless the backend configuration changes.
```

## Vérification du state dans Azure Blob
```bash
az storage blob list --container-name tfstate --account-name <storage_account>
```
**Attendu :** Le blob `training/<team>/dev/02-day1-state.tfstate` existe.

## Plan post-migration
```bash
terraform plan
```
**Attendu :** `No changes. Your infrastructure matches the configuration.`

## Test de verrouillage (lease)
```bash
# Terminal 1 :
terraform plan  # acquiert le lease

# Terminal 2 (simultanément) :
terraform plan  # doit échouer avec une erreur de verrou
```
**Attendu (terminal 2) :**
```
Error: Error acquiring the state lock
```

## Récupération du state
```bash
terraform state pull
```
**Attendu :** Sortie JSON de l'état avec un tableau `resources` contenant 3 ressources.

