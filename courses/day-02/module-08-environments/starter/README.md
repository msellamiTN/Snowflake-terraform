# Code de départ — M8 : Stratégies d'environnements

## Ce qu'il faut copier

```powershell
# Racine DEV
Copy-Item -Recurse -Path "..\..\..\project\03-day2-modules\environments\dev\*" -Destination ".\starter\dev\"
# Racine TEST
Copy-Item -Recurse -Path "..\..\..\project\03-day2-modules\environments\test\*" -Destination ".\starter\test\"
```

## État de départ

Les participants configurent des clés backend séparées et comparent les plans DEV vs TEST.

## Validation

```bash
cd starter/dev && terraform init -backend=false && terraform validate
cd ../test && terraform init -backend=false && terraform validate
```

