# Résultat attendu — M14

## Terraform

```text
Apply complete!
Outputs:
data_products = {
  "FINANCE" = { ... }
  "SALES" = { ... }
}
```

## Snowflake

Pour chaque domaine :

- `DB_{DOMAIN}_DEV` ;
- schemas `RAW`, `SILVER`, `GOLD` ;
- stage `STG_{DOMAIN}_RAW_DEV` ;
- rôles `RL_{DOMAIN}_PRODUCER_DEV` et `RL_{DOMAIN}_READER_DEV` ;
- Future Grants SELECT au rôle lecteur.

Après Snow CLI, les vues GOLD sont interrogeables et un nouveau `terraform plan` indique `No changes`.

