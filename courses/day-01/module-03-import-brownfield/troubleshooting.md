# Dépannage — M3 : Import & Brownfield

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `Error acquiring the state lock` lors de `terraform import` | Un précédent processus Terraform a laissé un verrou (plan/apply interrompu) | Vérifier qu'aucun `plan`/`apply` n'est actif, puis `terraform force-unlock <LOCK_ID>` avec l'ID affiché dans le message |
| `terraform import` échoue : `object does not exist` | Nom d'objet incorrect ou pas encore créé | Vérifier que l'objet existe : `snow sql -c training -q "SHOW DATABASES LIKE 'DB_APP01_BROWNFIELD_DEV'"` (avec votre préfixe) |
| `terraform plan` montre "to create" après import | Bloc de ressource non ajouté à la config | Ajouter le bloc `resource` correspondant à l'objet importé dans `main.tf` avant l'import |
| `terraform plan` montre "to delete" après bloc moved | Syntaxe du bloc moved incorrecte | S'assurer que les adresses `from` et `to` sont correctes dans le bloc `moved {}` |
| `terraform state mv` échoue : `Cannot move to existing address` | L'adresse cible existe déjà dans le state | Supprimer la ressource cible du state d'abord, ou utiliser une adresse différente |
| `terraform plan` montre 2 ressources (ancienne + nouvelle) après move | Le move n'a pas été appliqué | Exécuter `terraform state mv` ou ajouter un bloc `moved {}` avant le prochain plan |
| `Error: Resource already managed by Terraform` | Tentative d'importer un objet déjà dans le state | Supprimer du state d'abord : `terraform state rm snowflake_database.brownfield` |
| Bloc `moved` ignoré | Version Terraform < 1.1 | Utiliser Terraform 1.14.5 comme spécifié |
| `snow sql` échoue : `Unknown connection 'training'` | Snow CLI non configuré | Relancer `Learner-Login` ou configurer la connexion `training` dans `~/.snowflake/config.toml` |
| `terraform validate` échoue : `Reference to undeclared variable` | `var.learner_prefix` n'existe pas dans le starter | Utiliser le nom littéral de la database (par exemple `DB_APP01_BROWNFIELD_DEV`) au lieu d'une variable |
| `generated.tf` vide ou absent | Import non réussi ou plan sans drift | Vérifier que l'import a réussi, puis relancer `terraform plan -generate-config-out=generated.tf` |
