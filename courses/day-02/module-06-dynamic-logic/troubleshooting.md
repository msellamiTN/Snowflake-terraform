# Dépannage — M6 : Logique dynamique & for_each

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` échoue : `invalid for_each argument` | for_each sur un type non-map/list | S'assurer que `for_each` utilise `var.schemas` (set) ou `var.warehouses` (map) |
| `Error: duplicate key in for_each` | Entrées en double dans la map/set d'entrée | Supprimer les doublons de la variable `schemas` ou `warehouses` |
| `flatten()` produit une structure incorrecte | Flatten imbriqué pas assez profond | Utiliser le pattern `flatten([... for ... : [ for ... : { ... } ]])` |
| `terraform plan` montre 0 schéma | Variable `schemas` vide | Définir `schemas = ["RAW", "SILVER", "GOLD"]` dans tfvars |
| `Error: Invalid object` pour warehouse | Attributs requis manquants | S'assurer que chaque warehouse a au moins l'attribut `size` |
| `snowflake_grant_account_role` échoue : `role not found` | Rôle pas encore créé | Ajouter `depends_on = [snowflake_account_role.this]` |
| `for_each` sur `var.users` échoue | La map users a un mauvais type | S'assurer que `users` est `map(object({roles = list(string), ...}))` |

