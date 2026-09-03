# Solution de référence — M2 : Gestion du State

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `courses/day-01/module-02-state-management/starter/main.tf` |
| `backend.tf` | Construit par l'apprenant pendant le lab (voir `backend.tf.example`) |
| `provider.tf` | `courses/day-01/module-02-state-management/starter/provider.tf` |
| `variables.tf` | `courses/day-01/module-02-state-management/starter/variables.tf` |

## Contrat technique

| Élément | Valeur attendue |
|---|---|
| Dossier de travail | `environments/dev/` |
| Clé de state | `training/APP01/dev/terraform.tfstate` (avec préfixe apprenant) |
| Authentification backend | `use_azuread_auth = true` |
| Authentification Azure CLI | `--auth-mode login` |
| Rôle data-plane | `Storage Blob Data Contributor` |
| Resource Group | `rg-data2ai-tf-state` |
| Storage Account | `sadata2aitfstatemsn` |
| Container | `tfstate` |

## Résultat attendu

- State migré du local vers Azure Blob avec `terraform init -migrate-state`
- `terraform state list` affiche les ressources M1 (database, schemas, warehouse)
- `terraform plan` ne montre aucun changement après migration
- Le blob `training/APP01/dev/terraform.tfstate` existe dans Azure
- Le test de verrouillage (Blob Lease) bloque le second terminal
- `terraform_remote_state` lit l'output `raw_database_name` depuis le state DEV

## Checklist formateur

- [ ] Terraform `v1.14.5` vérifié au préflight
- [ ] `backend.tf` contient `use_azuread_auth = true`
- [ ] La clé contient le préfixe apprenant réel (pas `APP01` littéral)
- [ ] Les commandes Azure Storage utilisent `--auth-mode login`
- [ ] Le SP a `Storage Blob Data Contributor` (pas seulement `Contributor`)
- [ ] Aucun state, plan ou secret n'est suivi par Git
- [ ] Le test de lock a échoué dans le second terminal puis réussi après libération
