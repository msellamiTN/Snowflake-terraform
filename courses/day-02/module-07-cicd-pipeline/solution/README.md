# Solution de référence — M7 : Pipeline CI/CD

## Source

| Fichier | Chemin source |
|---------|---------------|
| Pipeline ADO | `azure-pipelines.yml` |
| Workflow GH Actions | `.github/workflows/terraform.yml` |

## Résultat attendu

- Le pipeline se déclenche sur PR et push vers main
- Stage Validate : format, tflint, validation matrice des 9 racines
- Stage Plan : génère et publie l'artefact de plan
- Stage Apply : consomme l'artefact de plan, applique sur dev
- Stage Audit : drift check + dbt FinOps build

