# Dépannage — M8 : Stratégies d'environnements

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` pour TEST montre les ressources DEV | Mauvais fichier de state | Vérifier que `backend.tf` a `key = "training/<team>/test/03-day2-modules.tfstate"` |
| `Error: database already exists` | DEV et TEST partagent le même nom de base | S'assurer que la variable `environment` diffère : `DEV` vs `TEST` |
| `terraform init` télécharge le même state pour les deux envs | Même clé backend | Chaque racine d'environnement doit avoir une `key` unique dans `backend.tf` |
| Confusion avec `terraform workspace` | Workspaces non utilisés dans ce cours | Utiliser des répertoires séparés (`environments/dev`, `environments/test`) au lieu des workspaces |
| `deployment_mode` non défini | Variable manquante dans tfvars | Ajouter `deployment_mode = "training"` dans `terraform.tfvars` |
| `terraform plan -var="deployment_mode=production"` échoue | Clé privée non configurée | Définir `private_key_path` dans tfvars ou utiliser `deployment_mode = "training"` |
| Erreur de grant cross-environnement | Rôle de DEV référencé dans TEST | Chaque environnement crée ses propres rôles avec suffixe `_DEV` ou `_TEST` |

