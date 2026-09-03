# Dépannage — M4 : Variables, Outputs & Lifecycle

> [<- Jour 1](../README.md) · [<- Module precedent](../module-03-import-brownfield/lab.md) · **Module 4** · [Jour 2 ->](../../day-02/README.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform validate` échoue : `Invalid value for variable` | Validation de variable échouée | Vérifier le bloc `validation` dans `variables.tf` et s'assurer que l'entrée correspond aux valeurs autorisées |
| `terraform plan` échoue : `Required variable not set` | Variable requise manquante | Fournir via `-var`, `-var-file`, ou `terraform.tfvars` |
| `terraform output` retourne vide | Aucun output défini ou state vide | Ajouter des blocs `output` dans `outputs.tf` et exécuter `terraform apply` |
| `prevent_destroy` bloque une destruction légitime | Protection lifecycle activée | Retirer `prevent_destroy` ou mettre à `false` temporairement (approbation formateur) |
| `depends_on` ne fonctionne pas | Mauvaise référence de ressource | S'assurer que `depends_on` référence des adresses de ressources, pas des noms de variables |
| `terraform plan -var-file` échoue : `file not found` | Mauvais chemin vers tfvars | Vérifier le chemin : `environments/dev.tfvars` relatif à la racine du module |
| `Error: Invalid type` pour une variable | Incompatibilité de type | S'assurer que le type de variable correspond à l'entrée (ex. `list(string)` pas `string`) |
| `terraform fmt -check` échoue | Code non formaté | Exécuter `terraform fmt` pour formater automatiquement |

