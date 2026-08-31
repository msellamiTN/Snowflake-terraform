# Résultat attendu — M6 : Logique dynamique & for_each

## Landing Zone avec schémas dynamiques
```bash
cd project/03-day2-modules/environments/dev
terraform plan
```
**Attendu :** Schémas créés via `for_each` : `RAW`, `SILVER`, `GOLD` dans `DB_RAW_DEV`.

## Map de warehouses
```bash
terraform plan
```
**Attendu :** 2 warehouses : `WH_ETL_DEV` (X-SMALL) et `WH_ANALYTICS_DEV` (SMALL).

## Affectation utilisateur-rôle
```bash
terraform plan
```
**Attendu :** Utilisateurs créés depuis la map `users` avec rôles assignés via `for_each` sur liste aplatie.

## Vérification Snowflake
```sql
SHOW SCHEMAS IN DATABASE DB_RAW_DEV;
SHOW WAREHOUSES;
SHOW USERS;
SHOW GRANTS TO USER <username>;
```
**Attendu :** Schémas, warehouses, utilisateurs et grants tous présents.

## Comptage dynamique des ressources
```bash
terraform state list | wc -l
```
**Attendu :** Le compte correspond à : 2 bases + 3 schémas + 2 warehouses + 1 monitor + tags + rôles + grants.

