# Solution de référence — M6 : Logique dynamique & for_each

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `project/03-day2-modules/environments/dev/main.tf` |
| Module : `landing-zone/schemas.tf` | `project/03-day2-modules/modules/landing-zone/schemas.tf` |
| Module : `landing-zone/main.tf` | `project/03-day2-modules/modules/landing-zone/main.tf` (warehouse for_each) |
| Module : `user-role-assignment` | `project/03-day2-modules/modules/user-role-assignment/main.tf` |

## Résultat attendu

- `for_each` sur les schémas crée RAW, SILVER, GOLD
- `for_each` sur les warehouses crée ETL et ANALYTICS
- `flatten()` + `for_each` pour les grants utilisateur-rôle
- `terraform state list` affiche les ressources dynamiques

