# Résultat attendu — M11 : RBAC & Future Grants

> [<- Jour 4](../README.md) · [<- Jour 3](../../day-03/README.md) · **Module 11** · [Module suivant ->](../module-12-capstone/lab.md)

## Hiérarchie des rôles
```sql
SHOW ROLES LIKE 'RL_%_DEV';
```
**Rôles attendus :**
- `RL_SYSADMIN_DEV` (parent : `SYSADMIN`)
- `RL_SECURITYADMIN_DEV` (parent : `SECURITYADMIN`)
- `RL_USERADMIN_DEV` (parent : `USERADMIN`)
- `RL_DATA_ENGINEER_DEV` (parent : `RL_SYSADMIN_DEV`)
- `RL_DATA_ANALYST_DEV` (parent : `RL_DATA_ENGINEER_DEV`)
- `RL_DATA_STEWARD_DEV` (parent : `RL_DATA_ANALYST_DEV`)

## Grants sur rôles
```sql
SHOW GRANTS TO ROLE RL_DATA_ENGINEER_DEV;
```
**Attendu :**
- `USAGE` sur `WH_ETL_DEV`
- `OPERATE` sur `WH_ETL_DEV`
- `USAGE, CREATE SCHEMA` sur `DB_RAW_DEV`

## Future Grants
```sql
SHOW FUTURE GRANTS IN DATABASE DB_RAW_DEV;
```
**Attendu :**
- `SELECT` sur futures `TABLES` dans `DB_RAW_DEV` pour `RL_DATA_ANALYST_DEV`
- `SELECT, INSERT, UPDATE, DELETE, TRUNCATE` sur futures `TABLES` dans `DB_RAW_DEV` pour `RL_DATA_ENGINEER_DEV`

```sql
SHOW FUTURE GRANTS IN DATABASE DB_CURATED_DEV;
```
**Attendu :**
- `SELECT` sur futures `TABLES` dans `DB_CURATED_DEV` pour `RL_DATA_ANALYST_DEV`
- `SELECT` sur futures `TABLES` dans `DB_CURATED_DEV` pour `RL_DATA_STEARD_DEV`

## Affectation utilisateur-rôle
```sql
SHOW GRANTS TO USER <username>;
```
**Attendu :** L'utilisateur a des rôles assignés via le module `user-role-assignment`.

## Couverture des tags
```sql
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES WHERE TAG_NAME IN ('TAG_ENVIRONMENT', 'TAG_TEAM', 'TAG_COST_CENTER');
```
**Attendu :** Tags associés aux bases de données et warehouses.

## Resource Monitor
```sql
SHOW RESOURCE MONITORS LIKE 'RM_BUDGET_DEV';
```
**Attendu :** `RM_BUDGET_DEV` avec `CREDIT_QUOTA`, `NOTIFY_AT = 75,90`, `SUSPEND_AT = 100`, `SUSPEND_IMMEDIATE_AT = 110`.

