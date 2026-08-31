# Solution de référence — M2 : Gestion du State

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `project/02-day1-state/main.tf` |
| `backend.tf.example` | `project/02-day1-state/backend.tf.example` |
| `provider.tf` | `project/02-day1-state/provider.tf` |
| `variables.tf` | `project/02-day1-state/variables.tf` |

## Résultat attendu

- State migré du local vers Azure Blob
- Clé de state : `training/<team>/dev/02-day1-state.tfstate`
- `terraform plan` ne montre aucun changement après migration

