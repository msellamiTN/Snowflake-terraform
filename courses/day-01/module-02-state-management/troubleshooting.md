# Dépannage — M2 : Gestion du State

> [<- Jour 1](../README.md) · [<- Module precedent](../module-01-iac-workflow/lab.md) · **Module 2** · [Module suivant ->](../module-03-import-brownfield/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform init -migrate-state` échoue : `storage account not found` | Mauvais nom de compte de stockage | Vérifier que `backend.tf` contient le bon `storage_account_name` (`sadata2aitfstatemsn`) |
| `Error acquiring the state lock` | Un autre processus détient le lease Blob | Attendre que l'autre processus se termine, ou `terraform force-unlock` (approbation formateur) |
| `Error: blob not found` après migration | Mauvais chemin de clé de state | Vérifier que `key` dans `backend.tf` correspond à `training/APP01/dev/terraform.tfstate` (avec votre préfixe) |
| `terraform state pull` retourne vide | State non migré correctement | Relancer `terraform init -migrate-state` avec la bonne configuration backend |
| `403 Forbidden` sur Azure Blob | Identifiants ARM erronés ou rôle data-plane absent | Relancer `Learner-Login` ; vérifier que le SP a `Storage Blob Data Contributor` (pas seulement `Contributor`) |
| `terraform plan` montre toutes les ressources "to create" après migration | State perdu ou mauvaise clé | Vérifier si l'ancien `terraform.tfstate` existe encore ; comparer la clé et relancer la migration |
| `Lease already present` sans processus actif | Lease périmé d'un processus planté | `az storage blob lease break --blob-name <key> --container-name tfstate --account-name <account> --auth-mode login` |
| `backend.tf` absent ou vide | Fichier non créé | Créer `backend.tf` avec le bloc `backend "azurerm"` en suivant le lab ; voir `backend.tf.example` pour référence |
| `ARM_RESOURCE_GROUP` ou `ARM_STORAGE_ACCOUNT` vides | `.env` non chargé ou script `Learner-Login` non exécuté | Vérifier que `.env` contient ces variables et relancer `Learner-Login` |
| `The selected region is currently not accepting new customers` | `westeurope` ou autre région saturée | Changer `ARM_LOCATION` dans `.env` vers `northeurope`, `francecentral` ou une autre région disponible |
| `argument --name/--resource-group expected one argument` | Variable `$env:ARM_RESOURCE_GROUP` vide sous PowerShell | Vérifier avec `Write-Host "RG: $env:ARM_RESOURCE_GROUP"` et relancer `Learner-Login` |
| `az storage container create` demande des credentials | Pas de `--auth-mode login` | Ajouter `--auth-mode login` à la commande ou utiliser `Learner-Login` qui connecte le SP |
| Terraform refuse `required_version = 1.14.5` | Terraform 1.15+ dans le PATH avant 1.14.5 | Relancer `Install-Tools.ps1 -Force`, fermer/rouvrir le terminal, ou utiliser `$HOME\.data2ai\bin\terraform.exe` |
| `No credentials found` ou warning account key | `--auth-mode login` absent | Ajouter `--auth-mode login` aux commandes `az storage` ; le backend doit avoir `use_azuread_auth = true` |
| `AuthorizationPermissionMismatch` sur Blob | Rôle `Storage Blob Data Contributor` absent ou en propagation | Faire attribuer le rôle au SP sur le Storage Account, attendre la propagation RBAC, retester |

---

## Execution policy PowerShell

**Symptome :**

```text
Impossible de charger le fichier ...ps1, car l'execution de scripts est desactivee.
```

**Cause :** La politique d'execution PowerShell est reglee sur `Restricted`.

**Correction :**

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

> `RemoteSigned` autorise les scripts locaux. C'est le parametre standard pour un poste de formation.

**Alternative ponctuelle :**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\<script-name>.ps1
```
