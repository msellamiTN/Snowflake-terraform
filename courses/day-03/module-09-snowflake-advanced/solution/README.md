# Solution de référence — M9 : Snowflake avancé

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `project/05-capstone/environments/dev/main.tf` |
| `provider.tf` | `project/05-capstone/environments/dev/provider.tf` |

## Résultat attendu

- Intégration de stockage `SI_AZURE_DEV` créée
- File format `FF_CSV_RAW` créé
- External stage `STG_AZURE_RAW` créée
- `SHOW STAGES`, `SHOW FILE FORMATS`, `SHOW INTEGRATIONS` retournent les objets attendus

