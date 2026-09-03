# Résultat attendu — M7 : Pipeline CI/CD (Azure DevOps)

> [<- Jour 2](../README.md) · [<- Module precedent](../module-06-dynamic-logic/lab.md) · **Module 07** · [Module suivant ->](../module-08-environments/lab.md)

## Déclenchement du pipeline
Créer une PR vers `main` avec des modifications dans `project/05-capstone/**`, `project/03-day2-modules/modules/**` ou `azure-pipelines.yml`.
**Attendu :** Le pipeline déclenche les stages `Validate` → `Plan`.

Sur `main`, le merge déclenche `Validate` → `Plan` → `Apply` → `Audit`.

## Stage Validate
**Jobs attendus :**
- `Format & Lint` : `terraform fmt -check`, `tflint` et `tfsec` sur `project/05-capstone` réussissent
- `Validate Capstone Root` : `terraform init -backend=false && terraform validate` réussit pour `project/05-capstone/environments/dev`

## Stage Plan
**Attendu :**
- `terraform plan -out=tfplan` génère l'artefact `tfplan`
- `tfplan.txt` publié comme artefact texte lisible
- Le plan montre les changements de ressources attendus

> Note : le stage Plan s'exécute désormais sur PR **et** sur `main` afin de produire l'artefact consommé par `Apply`.

## Stage Apply (merge vers main)
**Attendu :**
- Télécharge l'artefact `tfplan` du run courant
- `terraform apply -auto-approve tfplan` réussit
- Message `Apply complete!`

## Stage Audit (post-apply)
**Attendu :**
- `terraform plan -detailed-exitcode` retourne 0
- Message `No drift detected.`

## Artefacts du pipeline
| Artefact | Contenu |
|----------|---------|
| `tfplan` | Fichier de plan binaire |
| `tfplan-text` | Texte du plan lisible |

## Politique de branche
- PR requise pour merger vers `main`
- Au moins 1 approbation de reviewer
- Le pipeline doit réussir avant le merge

