# Dépannage — M8 : Stratégies d'environnements

> [<- Jour 2](../README.md) · [<- Module precedent](../module-07-cicd-pipeline/lab.md) · **Module 08** · [Jour 3 ->](../../day-03/README.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` pour UAT ou PROD montre les ressources DEV | Mauvais fichier de state | Vérifier les clés `training/APP01/uat/terraform.tfstate` et `training/APP01/prod/terraform.tfstate` ; remplacer `APP01` par le préfixe apprenant. |
| `Error: database already exists` | Deux environnements partagent le même nom de base | S'assurer que la variable `environment` diffère : `DEV`, `UAT` ou `PROD`. |
| `terraform init` télécharge le même state pour deux environnements | Même clé backend | Chaque racine doit avoir sa clé `training/APP01/<env>/terraform.tfstate` unique et `use_azuread_auth = true`. |
| `AuthenticationFailed` ou Azure CLI demande une account key | Authentification data-plane implicite | Se connecter avec `Learner-Login`, vérifier le rôle `Storage Blob Data Contributor` et ajouter `--auth-mode login` aux commandes `az storage`. |
| La liste des blobs est vide ou inaccessible | Mauvais préfixe APP ou droits RBAC non propagés | Utiliser `--prefix "training/APP01/" --auth-mode login`, vérifier le préfixe apprenant et attendre quelques minutes après l'attribution RBAC. |
| Confusion avec `terraform workspace` | Workspaces non utilisés dans ce cours | Utiliser des répertoires séparés (`environments/dev`, `environments/uat`, `environments/prod`). |
| `deployment_mode` non défini | Variable manquante dans tfvars | Ajouter `deployment_mode = "training"` dans `terraform.tfvars`. |
| `terraform plan -var="deployment_mode=production"` échoue | Clé privée non configurée | Définir `private_key_path` dans tfvars ou utiliser `deployment_mode = "training"`. |
| Erreur de grant cross-environnement | Rôle d'un autre environnement référencé | Chaque environnement crée ses propres rôles avec le suffixe `_DEV`, `_UAT` ou `_PROD`. |
