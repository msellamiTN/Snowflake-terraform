# Code de départ — M6 : Logique dynamique & for_each

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\03-day2-modules\environments\dev\*" -Destination ".\starter\"
```

## État de départ

Les participants démarrent avec la solution M5 et ajoutent :
- Liste dynamique de schémas avec `for_each`
- Map de warehouses avec `for_each`
- Module user-role-assignment avec `for_each` aplati

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir
```

