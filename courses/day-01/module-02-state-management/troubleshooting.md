# Dépannage — M2 : Gestion du State

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform init -migrate-state` échoue : `storage account not found` | Mauvais nom de compte de stockage | Vérifier que `backend.hcl` contient le bon `storage_account_name` issu de `00-bootstrap` |
| `Error acquiring the state lock` | Un autre processus détient le lease Blob | Attendre que l'autre processus se termine, ou `terraform force-unlock` (approbation formateur) |
| `Error: blob not found` après migration | Mauvais chemin de clé de state | Vérifier que `key` dans `backend.hcl` correspond à `training/<team>/dev/02-day1-state.tfstate` |
| `terraform state pull` retourne vide | State non migré correctement | Relancer `terraform init -migrate-state` avec la bonne configuration backend |
| `403 Forbidden` sur Azure Blob | Identifiants ARM erronés ou expirés | Relancer `az login` et vérifier `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` |
| `terraform plan` montre toutes les ressources "to create" après migration | State perdu pendant la migration | Vérifier si l'ancien `terraform.tfstate` existe encore ; relancer la migration |
| `Lease already present` sans processus actif | Lease périmé d'un processus planté | `az storage blob lease break --blob-name <key> --container-name tfstate --account-name <account>` |
| `backend.tf.example` introuvable | Fichier non renommé | Copier `backend.tf.example` vers `backend.tf` et remplir les valeurs issues de `00-bootstrap` |

