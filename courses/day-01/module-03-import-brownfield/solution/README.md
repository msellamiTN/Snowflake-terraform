# Solution de référence — M3 : Import & Brownfield

## Source

| Technique | Source |
|-----------|--------|
| `terraform import` | Sur les ressources de `project/01-day1-basics` |
| Blocs `moved {}` | Ajoutés à `main.tf` pendant le lab |
| `terraform state mv` | Commandes de manipulation du state |

## Résultat attendu

- L'objet importé apparaît dans le state
- La config générée correspond à l'objet importé
- Le bloc `moved` ou `state mv` renomme l'adresse de la ressource sans destruction
- `terraform plan` ne montre aucun changement après refactor

