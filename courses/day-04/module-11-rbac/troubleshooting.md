# Dépannage — M11 : RBAC & Future Grants

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `SHOW ROLES` affiche d'anciens noms de rôles | Rôles non renommés | Utiliser des blocs `moved {}` ou `terraform state mv` pour un renommage sécurisé |
| `Error: role already exists` | Rôle créé hors Terraform | Importer : `terraform import snowflake_account_role.this RL_DATA_ENGINEER_DEV` |
| Future grant échoue : `insufficient privileges` | Le rôle manque `MANAGE GRANTS` | Utiliser `SECURITYADMIN` ou `ACCOUNTADMIN` pour les opérations de grant |
| `SHOW FUTURE GRANTS` retourne vide | Future grants non appliqués | Exécuter `terraform apply` et vérifier les ressources `snowflake_grant_privileges_to_account_role.future` |
| `Error: duplicate grant` | Même privilège accordé deux fois | Vérifier la map `role_definitions` pour des grants chevauchants |
| Hiérarchie de rôles incorrecte : `parent_role` introuvable | Faute de frappe dans la clé `parent_role` | S'assurer que `parent_role` dans `role_definitions` correspond à une clé ou un nom de rôle système |
| `terraform plan` montre tous les rôles "to create" | `role_definitions` a changé | Utiliser des blocs `moved` ou importer les rôles existants avant d'appliquer |
| Association de tag échoue : `tag not found` | Tag pas encore créé | Ajouter `depends_on = [module.landing_zone]` aux ressources d'association de tags |
| `Error: cannot grant to self` | Rôle accordé à lui-même | Vérifier que `parent_role` ne crée pas de dépendance circulaire |

