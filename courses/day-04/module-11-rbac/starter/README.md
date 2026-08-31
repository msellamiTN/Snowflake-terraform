# Code de départ — M11 : RBAC & Future Grants

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\04-day3-rbac\environments\dev\*" -Destination ".\starter\"
```

## État de départ

Les participants démarrent avec la racine d'environnement RBAC. Le module `rbac` a des `role_definitions` par défaut. Les participants :
1. Examinent le modèle de rôles data-driven
2. Ajoutent des définitions de rôles personnalisées
3. Appliquent et vérifient les grants
4. Vérifient la couverture des future grants

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir
```

