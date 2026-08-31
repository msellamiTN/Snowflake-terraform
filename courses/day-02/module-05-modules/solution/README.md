# Solution de référence — M5 : Modules & Git Registry

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `project/03-day2-modules/environments/dev/main.tf` |
| `provider.tf` | `project/03-day2-modules/environments/dev/provider.tf` |
| `variables.tf` | `project/03-day2-modules/environments/dev/variables.tf` |
| `versions.tf` | `project/03-day2-modules/environments/dev/versions.tf` |
| Module : `landing-zone` | `project/03-day2-modules/modules/landing-zone/` |
| Module : `crypto` | `project/03-day2-modules/modules/crypto/` |
| Module : `rbac` | `project/03-day2-modules/modules/rbac/` |

## Résultat attendu

- 3 appels de modules dans `main.tf`
- `terraform plan` montre 10+ ressources
- Les outputs du module exposent les noms de bases, warehouses et rôles
- La variante Git utilise une URL `source` statique et un tag `?ref=` immuable

