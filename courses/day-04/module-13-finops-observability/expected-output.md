# Résultat attendu — M13

## dbt

```text
Completed successfully
PASS=... WARN=0 ERROR=0 SKIP=0
```

## Objets attendus

- `DB_FINOPS_DEV.STAGING.STG_WAREHOUSE_METERING`
- `DB_FINOPS_DEV.STAGING.STG_QUERY_HISTORY`
- `DB_FINOPS_DEV.MARTS.MART_WAREHOUSE_CREDITS_DAILY`
- `DB_FINOPS_DEV.MARTS.MART_RESOURCE_MONITOR_RISK`
- `DB_FINOPS_DEV.MARTS.MART_INACTIVE_WAREHOUSES`
- `DB_FINOPS_DEV.MARTS.MART_EXPENSIVE_QUERIES`
- `DB_FINOPS_DEV.MARTS.MART_STORAGE_TRENDS`

## Preuve d'acceptation

Le participant fournit le résumé `dbt build`, une ligne de chaque mart et une recommandation FinOps argumentée. Une source vide n'est pas un échec si la latence `ACCOUNT_USAGE` est démontrée.

