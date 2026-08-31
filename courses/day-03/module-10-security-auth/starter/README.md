# Code de départ — M10 : Sécurité & Authentification

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\05-capstone\environments\dev\*" -Destination ".\starter\"
```

## État de départ

Les participants démarrent avec la racine capstone DEV. Le bloc du module `key-vault-rsa` est commenté. Les participants :
1. Décommentent le bloc du module `key_vault_rsa`
2. Configurent les provider aliases pour `sysadmin`, `useradmin`, `securityadmin`
3. Testent l'authentification JWT
4. Démontrent la rotation de clé

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir
```

