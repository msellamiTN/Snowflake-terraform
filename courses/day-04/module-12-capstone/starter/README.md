# Code de départ — M12 : Capstone

## Ce qu'il faut copier

```powershell
# Racine capstone DEV
Copy-Item -Recurse -Path "..\..\..\project\05-capstone\environments\dev\*" -Destination ".\starter\"
# Projet FinOps
Copy-Item -Recurse -Path "..\..\..\finops\*" -Destination ".\starter\finops\"
```

## État de départ

Les participants démarrent avec le capstone complet. Ils :
1. Configurent `terraform.tfvars` avec le code d'équipe et les identifiants
2. Exécutent `terraform init && terraform plan && terraform apply`
3. Exécutent dbt FinOps : `dbt deps && dbt build`
4. Vérifient le zero drift
5. Présentent l'architecture

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir
cd finops
dbt deps
dbt build --target dev  # tous les tests réussissent
```

