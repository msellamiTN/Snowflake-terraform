# Solution M13

La solution de référence est `finops/` :

- `models/staging/` normalise `ACCOUNT_USAGE` ;
- `models/marts/` fournit les indicateurs opérationnels ;
- `models/schema.yml` porte les tests ;
- `azure-pipelines.yml`, stage Audit, exécute `dbt build --target dev`.

La preuve de réussite est décrite dans `../expected-output.md`. Les identifiants restent dans `~/.dbt/profiles.yml` ou dans le Variable Group Azure DevOps.

