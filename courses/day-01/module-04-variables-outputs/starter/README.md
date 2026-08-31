# Code de départ — M4 : Variables, Outputs & Lifecycle

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\01-day1-basics\*" -Destination ".\starter\"
```

## État de départ

Les participants ajoutent :
- Des blocs `validation` aux variables
- Des blocs `output` dans `outputs.tf`
- Des blocs `lifecycle` aux ressources
- `environments/dev.tfvars` et `environments/test.tfvars`

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir
```

