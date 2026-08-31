# Code de départ — M1 : Workflow IaC

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\01-day1-basics\*" -Destination ".\starter\"
```

Ou utiliser directement la racine du projet :
```powershell
cd ..\..\..\project\01-day1-basics
cp terraform.tfvars.example terraform.tfvars
```

## État de départ

Le code de départ est une racine Terraform minimale avec :
- `main.tf` — vide ou avec des blocs de ressources commentés
- `variables.tf` — déclarations de variables
- `provider.tf` — configuration du provider Snowflake
- `versions.tf` — contraintes de version

Les participants remplissent les blocs de ressources pendant le lab.

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir même avec un main.tf vide
```

