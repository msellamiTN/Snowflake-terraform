# Dépannage — M10 : Sécurité & Authentification

> [<- Jour 3](../README.md) · [<- Module precedent](../module-09-snowflake-advanced/lab.md) · **Module 10** · [Jour 4 ->](../../day-04/README.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `tls_private_key` dans le state | Attendu en formation ; la production utilise Key Vault | Utiliser le module `key-vault-rsa` qui stocke la clé dans Key Vault, pas dans les outputs |
| `390144 JWT token is invalid` après génération de clé | Clé publique non enregistrée auprès de l'utilisateur Snowflake | Vérifier que la ressource `snowflake_user` a `rsa_public_key` défini depuis l'output du module |
| `Key Vault name already exists` | Nom de KV globalement unique | Utiliser un nom unique : `kv-<project>-<env>-<random>` |
| `purge_protection_enabled cannot be disabled` | Paramètre irréversible | Une fois activé, ne peut être désactivé. Prévoir un Key Vault permanent. |
| `RBAC authorization not enabled` | Ancien mode access policy | Définir `enable_rbac_authorization = true` dans la ressource Key Vault |
| `Error: provider alias not found` | Alias non déclaré | Ajouter `alias = "sysadmin"` au bloc provider et référencer comme `snowflake.sysadmin` |
| `Error: role SYSADMIN not granted` | L'utilisateur n'a pas le rôle | Accorder le rôle dans Snowflake : `GRANT ROLE SYSADMIN TO USER <user>` |
| `private_key_path` introuvable | Mauvais chemin relatif | Depuis `05-capstone/environments/dev`, le chemin est `../../../../secrets/snowflake_key.p8` |
| `terraform output` montre la clé privée | Le module expose la clé privée | Utiliser le module `key-vault-rsa` (pas d'output de clé privée) au lieu du module `crypto` |
| Rotation de clé : `rsa_public_key_2 not set` | Rotation non activée | Définir `enable_key_rotation = true` dans l'appel du module |

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

