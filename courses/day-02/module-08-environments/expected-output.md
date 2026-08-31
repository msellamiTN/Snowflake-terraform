# Résultat attendu — M8 : Stratégies d'environnements

## Environnement DEV
```bash
cd project/03-day2-modules/environments/dev
terraform init
terraform plan
```
**Attendu :** Ressources avec le suffixe `_DEV`. Clé de state : `training/<team>/dev/03-day2-modules.tfstate`

## Environnement TEST
```bash
cd project/03-day2-modules/environments/test
terraform init
terraform plan
```
**Attendu :** Ressources avec le suffixe `_TEST`. Clé de state : `training/<team>/test/03-day2-modules.tfstate`

## PROD (plan uniquement)
```bash
cd project/05-capstone/environments/dev
terraform plan -var-file=terraform.tfvars -var="deployment_mode=production"
```
**Attendu :** Le plan réussit en montrant les ressources en mode production. Pas d'apply en formation.

## Isolation des clés de state
```bash
az storage blob list --container-name tfstate --account-name <account> --prefix training/<team>/
```
**Attendu :** Fichiers de state séparés pour dev et test :
- `training/<team>/dev/03-day2-modules.tfstate`
- `training/<team>/test/03-day2-modules.tfstate`

## Aucune ressource cross-environnement
```sql
SHOW DATABASES LIKE 'DB_RAW_DEV';
SHOW DATABASES LIKE 'DB_RAW_TEST';
```
**Attendu :** Les deux existent mais sont des bases séparées sans grants partagés.

