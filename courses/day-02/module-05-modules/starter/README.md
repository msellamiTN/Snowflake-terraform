# Code de départ — M5 : Modules & Git Registry

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\03-day2-modules\environments\dev\*" -Destination ".\starter\"
```

## État de départ

Les participants démarrent avec :
- `main.tf` vide (aucun appel de module)
- `provider.tf` avec le provider Snowflake
- `variables.tf` avec les variables d'environnement et de projet

Les participants ajoutent les appels de modules pour `landing-zone`, `crypto`, et `rbac`.

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir avec un main.tf vide
```

