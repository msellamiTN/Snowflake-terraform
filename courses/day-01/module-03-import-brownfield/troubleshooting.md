# Dépannage — M3 : Import & Brownfield

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform import` échoue : `object does not exist` | Nom d'objet incorrect ou pas encore créé | Vérifier que l'objet existe dans Snowflake : `SHOW DATABASES LIKE 'DB_RAW_DEV'` |
| `terraform plan` montre "to create" après import | Bloc de ressource non ajouté à la config | Ajouter le bloc de ressource correspondant à l'objet importé |
| `terraform plan` montre "to delete" après bloc moved | Syntaxe du bloc moved incorrecte | S'assurer que les adresses `from` et `to` sont correctes dans le bloc `moved {}` |
| `terraform state mv` échoue : `Cannot move to existing address` | L'adresse cible existe déjà dans le state | Supprimer la ressource cible du state d'abord, ou utiliser une adresse différente |
| `terraform plan` montre 2 ressources (ancienne + nouvelle) après move | Le move n'a pas été appliqué | Exécuter `terraform state mv` ou ajouter un bloc `moved {}` avant le prochain plan |
| `Error: Resource already managed by Terraform` | Tentative d'importer un objet déjà dans le state | Supprimer du state d'abord : `terraform state rm snowflake_database.raw` |
| Bloc `moved` ignoré | Version Terraform < 1.1 | Utiliser Terraform 1.14.5 comme spécifié |

