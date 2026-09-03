# Dépannage — M12 : Capstone

> [<- Jour 4](../README.md) · [<- Module precedent](../module-11-rbac/lab.md) · **Module 12** · [Module suivant ->](../module-13-finops-observability/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` montre 50+ ressources à créer | Premier run, aucun state | Attendu au premier apply. Exécuter `terraform apply`. |
| `Error: module source not found` | Chemin ou URL statique incorrecte | Corriger le littéral `source` puis relancer `terraform init -upgrade` |
| `dbt deps` échoue : `package not found` | Nom ou version de package incorrect | Vérifier que `packages.yml` a `getsnowflake/snowflake` version `4.6.0` et `dbt-utils` version `1.3.3` |
| `dbt build` échoue : `database not found` | Base FinOps non créée | Créer `DB_FINOPS_DEV` dans Snowflake ou laisser dbt la créer (nécessite le privilège `CREATE DATABASE`) |
| `dbt build` échoue : `ACCOUNT_USAGE access denied` | Le rôle manque `GOVERNANCE` ou `ACCOUNTADMIN` | Utiliser le rôle `ACCOUNTADMIN` dans le profil dbt |
| `dbt test` échoue : `accepted_values` | Statut de risque avec valeur inattendue | Vérifier `stg_resource_monitors` pour les cas limites ; ajuster `accepted_values` si nécessaire |
| `terraform plan -detailed-exitcode` retourne 2 | Drift détecté | Exécuter `terraform apply` pour réconcilier, ou investiguer les changements manuels |
| `snow sql` échoue : `connection not found` | Profil non configuré | Copier `profiles.yml.example` vers `~/.dbt/profiles.yml` et remplir les identifiants |
| `Error: data_mesh_spokes not configured` | Variable spokes vide | Ajouter des définitions de spokes dans `terraform.tfvars` ou laisser vide pour la plateforme de base |
| `terraform state list` montre des ressources inattendues | State d'un module précédent | Exécuter `terraform destroy` sur les anciennes ressources ou utiliser une clé de state propre |
| `dbt build` échoue : `ACCOUNT_USAGE latency` | Les vues ont 1-2h de latence | Attendre que les données se peuplent ; utiliser `--vars 'start_date: "2025-01-01"'` pour les données historiques |

