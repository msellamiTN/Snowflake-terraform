# Solution de référence — M4 : Variables, Outputs & Lifecycle

## Source

| Fichier | Chemin source |
|---------|---------------|
| `variables.tf` | `project/01-day1-basics/variables.tf` |
| `outputs.tf` | `project/01-day1-basics/outputs.tf` |
| `environments/dev.tfvars` | `project/01-day1-basics/environments/dev.tfvars` |
| `terraform.tfvars.example` | `project/01-day1-basics/terraform.tfvars.example` |

## Résultat attendu

- La validation de variables rejette les environnements invalides
- Les plans DEV et TEST produisent des ressources différemment nommées
- Les outputs exposent les noms de base, warehouse et schéma
- Les blocs `lifecycle { prevent_destroy = true }` bloquent la destruction

