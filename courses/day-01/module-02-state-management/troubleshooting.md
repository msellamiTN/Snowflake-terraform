# Dépannage — M2 : Gestion du State

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform init -migrate-state` échoue : `storage account not found` | Mauvais nom de compte de stockage | Vérifier que `backend.hcl` contient le bon `storage_account_name` issu de `00-bootstrap` |
| `Error acquiring the state lock` | Un autre processus détient le lease Blob | Attendre que l'autre processus se termine, ou `terraform force-unlock` (approbation formateur) |
| `Error: blob not found` après migration | Mauvais chemin de clé de state | Vérifier que `key` dans `backend.hcl` correspond à `training/<team>/dev/02-day1-state.tfstate` |
| `terraform state pull` retourne vide | State non migré correctement | Relancer `terraform init -migrate-state` avec la bonne configuration backend |
| `403 Forbidden` sur Azure Blob | Identifiants ARM erronés ou expirés | Relancer `Learner-Login` : `.\scripts\Learner-Login.ps1 -LearnerPrefix APP01` (le SP partagé a le rôle Contributor) |
| `terraform plan` montre toutes les ressources "to create" après migration | State perdu pendant la migration | Vérifier si l'ancien `terraform.tfstate` existe encore ; relancer la migration |
| `Lease already present` sans processus actif | Lease périmé d'un processus planté | `az storage blob lease break --blob-name <key> --container-name tfstate --account-name <account>` |
| `backend.tf.example` introuvable | Fichier non renommé | Copier `backend.tf.example` vers `backend.tf` et remplir les valeurs issues de `00-bootstrap` |
| `ARM_RESOURCE_GROUP` ou `ARM_STORAGE_ACCOUNT` vides | `.env` non chargé ou script `Learner-Login.ps1` non mis à jour | Vérifier que `.env` contient ces variables et relancer `Learner-Login.ps1` |
| `The selected region is currently not accepting new customers` | `westeurope` ou autre région saturée | Changer `ARM_LOCATION` dans `.env` vers `northeurope`, `francecentral` ou une autre région disponible |
| `argument --name/--resource-group expected one argument` | Variable `$env:ARM_RESOURCE_GROUP` vide sous PowerShell | Vérifier avec `Write-Host "RG: $env:ARM_RESOURCE_GROUP"` et relancer `Learner-Login.ps1` |
| `az storage container create` demande des credentials | Pas de `--auth-mode login` | Ajouter `--auth-mode login` à la commande ou utiliser `Learner-Login.ps1` qui connecte le SP |
| Terraform refuse `required_version = 1.14.5` | Terraform 1.15.1 dans le PATH avant 1.14.5 | Relancer `Install-Tools.ps1 -Force`, fermer/rouvrir le terminal, ou utiliser `$HOME\.data2ai\bin\terraform.exe` |

