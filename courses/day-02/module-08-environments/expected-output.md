# Résultat attendu — M8 : Stratégies d'environnements

## Environnements DEV, UAT et PROD

Depuis chaque répertoire `environments/dev`, `environments/uat` et `environments/prod` :

```bash
terraform init
terraform plan
```

**Attendu :** les ressources portent respectivement les suffixes `_DEV`, `_UAT` et `_PROD`. Les backends utilisent Microsoft Entra ID (`use_azuread_auth = true`) et les clés suivantes :

- `training/APP01/dev/terraform.tfstate`
- `training/APP01/uat/terraform.tfstate`
- `training/APP01/prod/terraform.tfstate`

Remplacez `APP01` par votre préfixe apprenant. Un identifiant `TEAMxx` est réservé à la piste collaborative et ne sert pas de frontière de state pour ces environnements.

## Isolation des clés de state

```bash
az storage blob list \
  --container-name "$ARM_CONTAINER" \
  --account-name "$ARM_STORAGE_ACCOUNT" \
  --prefix "training/APP01/" \
  --auth-mode login \
  --query "[].name" -o tsv
```

**Attendu :** trois fichiers de state séparés :

```text
training/APP01/dev/terraform.tfstate
training/APP01/uat/terraform.tfstate
training/APP01/prod/terraform.tfstate
```

## Aucune ressource cross-environnement

```sql
SHOW DATABASES LIKE 'APP01_RAW_DEV';
SHOW DATABASES LIKE 'APP01_RAW_UAT';
SHOW DATABASES LIKE 'APP01_RAW_PROD';
```

**Attendu :** les trois bases existent séparément, sans partage involontaire de ressources ou de grants entre environnements.
