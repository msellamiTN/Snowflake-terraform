# Code de départ — M9 : Snowflake avancé (Intégration Azure)

## Ce qu'il faut copier

```powershell
Copy-Item -Recurse -Path "..\..\..\project\05-capstone\environments\dev\*" -Destination ".\starter\"
```

## État de départ

Les participants démarrent avec la racine capstone DEV. Les ressources dépendant d'Azure sont commentées. Les participants :
1. Décommentent `data.azurerm_client_config`
2. Décommentent `snowflake_storage_integration_azure`
3. Décommentent `snowflake_stage_external_azure`
4. Configurent `snowflake_file_format`

## Validation

```bash
cd starter
terraform init -backend=false
terraform validate  # doit réussir avec les ressources Azure commentées
```

