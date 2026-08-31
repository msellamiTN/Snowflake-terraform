# Résultat attendu — M3 : Import & Brownfield

## Import d'un fixture
```bash
cd project/01-day1-basics
terraform import snowflake_database.raw DB_RAW_DEV
```
**Attendu :** `Import successful!` et `terraform state list` affiche `snowflake_database.raw`.

## Génération de config
```bash
terraform plan
```
**Attendu :** Montre du drift (objet importé pas encore dans la config). Ajouter ensuite le bloc de ressource dans `main.tf` et relancer le plan — devrait afficher `No changes`.

## Bloc moved
Après avoir renommé l'adresse de la ressource de `snowflake_database.raw` vers `snowflake_database.ingestion_raw` :
```bash
terraform plan
```
**Attendu :** `No changes. Your infrastructure matches the configuration.` (le bloc moved gère le renommage)

## State MV (alternative)
```bash
terraform state mv snowflake_database.raw snowflake_database.ingestion_raw
terraform plan
```
**Attendu :** `No changes.`

## Refactor sans destruction
Après avoir déplacé toutes les ressources vers des références de module :
```bash
terraform plan
```
**Attendu :** `No changes. Your infrastructure matches the configuration.` sans aucune ressource marquée pour destruction.

