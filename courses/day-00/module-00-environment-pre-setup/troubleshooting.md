# Dépannage — M0 : Préparation de l'environnement

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform: command not found` | Terraform absent du PATH | Ajouter le binaire Terraform au PATH système ou utiliser le chemin complet |
| `snow: command not found` | Snow CLI non installé | `pip install snowflake-cli` ou installer le MSI Snowflake CLI |
| `pip install snowflake-cli` echoue avec `Microsoft Visual C++ 14.0 is required` | Python 3.14 (ou autre version non precompilee) tente de compiler `pyyaml` | Passer par l'installateur MSI Snowflake CLI, ou utiliser Python 3.11-3.13 avec C++ Build Tools |
| `UserWarning: Encoding mismatch detected` | L'encodage Windows (cp1252) differe de celui attendu par `snow` | Definir `$env:SNOWFLAKE_CLI_ENCODING_FILE_IO='utf-8'`, `$env:SNOWFLAKE_CLI_ENCODING_SUBPROCESS='utf-8'`, `$env:SNOWFLAKE_CLI_ENCODING_STDOUT='utf-8'` et `$env:PYTHONUTF8='1'` |
| `az: command not found` | Azure CLI non installé | Télécharger depuis https://docs.microsoft.com/cli/azure/install-azure-cli |
| `390144 JWT token is invalid` | Format de clé incorrect ou utilisateur non configuré pour JWT | Vérifier le format PKCS#8 : `openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt`. Vérifier que `ALTER USER ... SET rsa_public_key = '...'` a été exécuté. |
| `390144 JWT token is invalid` (après correction de clé) | Décalage d'horloge système | S'assurer que NTP fonctionne ; le JWT tolère 60s de décalage |
| `250001 User DATA2AI does not exist` | Mauvais compte ou utilisateur | Vérifier que `$env:SNOWFLAKE_ACCOUNT` est `<snowflake-account>` et `$env:SNOWFLAKE_USER` est `DATA2AI` |
| `250003 User is blocked` | Utilisateur verrouillé | Le formateur doit `ALTER USER ... UNSET` ou réinitialiser le mot de passe |
| `Permission denied` sur snowflake_key.p8 | Permissions de fichier trop ouvertes | `chmod 600 secrets/snowflake_key.p8` (Linux) ou restreindre via ACL Windows |
| `openssl pkcs8: not a command` | OpenSSL non installé ou absent du PATH | Installer OpenSSL ou utiliser Git Bash qui l'inclut |
| `terraform init` échoue avec `no such host` | Réseau/proxy bloque registry.terraform.io | Configurer le proxy ou utiliser un miroir de providers hors ligne |
| `snow sql` retourne `403 Forbidden` | Rôle manque de permissions | Vérifier que `$env:SNOWFLAKE_ROLE` est défini sur `SYSADMIN` ou `ACCOUNTADMIN` |
| Le fichier de clé a une passphrase | `openssl genrsa` a créé avec passphrase | Régénérer : `openssl genrsa -out key.pem 2048` puis `openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt` |


