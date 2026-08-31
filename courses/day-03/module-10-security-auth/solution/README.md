# Solution de référence — M10 : Sécurité & Authentification

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `project/05-capstone/environments/dev/main.tf` (bloc key_vault_rsa) |
| `provider.tf` | `project/05-capstone/environments/dev/provider.tf` (aliases) |
| Module : `key-vault-rsa` | `project/03-day2-modules/modules/key-vault-rsa/` |
| Module : `crypto` | `project/03-day2-modules/modules/crypto/` (formation uniquement) |
| Runbook | `docs/key-rotation-runbook.md` |

## Résultat attendu

- Key Vault avec auth RBAC, soft delete, purge protection
- Clé RSA stockée dans Key Vault, clé publique enregistrée auprès de l'utilisateur Snowflake
- 4 provider aliases : défaut, sysadmin, useradmin, securityadmin
- Rotation de clé : seconde clé disponible via `next_secret_id`
- Aucun matériel de clé privée dans les outputs Terraform

