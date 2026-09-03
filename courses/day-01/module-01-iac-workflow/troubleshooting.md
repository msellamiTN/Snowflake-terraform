# Troubleshooting — M1

> [<- Jour 1](../README.md) · [<- Jour 0](../../day-00/README.md) · **Module 1** · [Module suivant ->](../module-02-state-management/lab.md)

| Symptôme | Diagnostic non destructif | Correction minimale | Prévention |
|---|---|---|---|
| Module M1 introuvable | Lister `student-track/module-01-*` | Utiliser la version refondue du dépôt | Préflight du catalogue |
| Workspace existe déjà | Vérifier le chemin affiché | Choisir un autre `WorkspaceRoot` | Ne jamais supprimer automatiquement |
| Branche créée au mauvais endroit | `git rev-parse --show-toplevel` | Recréer sous `$HOME/Data2AI-Labs` | Workspace hors dépôt du cours |
| Provider non trouvé | Lire `versions.tf`, tester accès registry | Corriger source/version puis `terraform init` | Checkpoint 1 |
| Profil Snowflake absent | `snow connection test -c terraform_svc` | Refaire le checkpoint M0 | Ne pas ajouter un password au provider |
| `Invalid account` | Tester le même profil avec Snow CLI | Corriger la configuration locale | Une seule source de connexion |
| Permission insuffisante | `SELECT CURRENT_ROLE()` puis erreur exacte | Demander le rôle sandbox prévu | Ne pas basculer génériquement sur ACCOUNTADMIN |
| Préfixe refusé | Lire le message de validation | Utiliser 2-12 caracteres majuscules/chiffres/underscore | Validation de variable |
| Resource already exists | Vérifier le préfixe et `terraform state list` | Les ressources existent déjà (test formateur). Changer de `LEARNER_PREFIX` (ex. APP01 -> APP01B) ou supprimer les ressources existantes pour refaire l'exercice de création | Préfixe unique par apprenant |
| `terraform fmt -check` échoue | `terraform fmt -diff` | Exécuter `terraform fmt` | Format avant chaque plan |
| Plan contient delete | `terraform show m01.tfplan` | Arrêter; vérifier workspace, state et préfixe | Revue obligatoire |
| Plan contient plus de 3 créations | Lire les adresses | Comparer `main.tf` au lab | Checkpoint structurel |
| Warehouse démarre à consommer | `SHOW WAREHOUSES` | Suspendre le warehouse si aucune requête n'est nécessaire | Initially suspended + auto-suspend |
| Second plan non vide | Lire l'attribut modifié | Corriger code ou drift intentionnellement | Ne pas appliquer sans comprendre |

## Resource already exists - Détail

L'objectif de M1 est de **créer** les ressources. Si elles existent déjà, deux options :

### Option A - Changer de préfixe (recommandé)

Modifiez `LEARNER_PREFIX` dans votre `.env` et `terraform.tfvars` :

```text
LEARNER_PREFIX=APP01B   # au lieu de APP01
```

> `[IMPORTANT]` Vous devez **aussi** mettre a jour `terraform.tfvars` dans `environments/dev/` :
> ```hcl
> learner_prefix = "APP01B"   # meme valeur que LEARNER_PREFIX dans .env
> ```
> Terraform lit les variables depuis `terraform.tfvars`, pas depuis `.env`.
> Si le plan affiche encore l'ancien prefixe, c'est que `terraform.tfvars` n'a pas ete mis a jour.

Relancez `terraform plan -out "m01.tfplan"` puis `terraform apply "m01.tfplan"`.

Vous créez ainsi vos propres ressources avec un préfixe unique.

### Option B - Supprimer les ressources existantes

Si le formateur vous autorise à nettoyer :

```bash
snow sql -c training -q "DROP DATABASE IF EXISTS APP01_RAW_DEV"
snow sql -c training -q "DROP WAREHOUSE IF EXISTS WH_APP01_ETL_DEV"
```

Puis relancez `terraform plan` et `terraform apply`.

> L'import de ressources existantes est couvert au **M3** (import-brownfield).
> Ne pas utiliser `terraform import` en M1.

## Informations à communiquer pour obtenir de l'aide

- OS et shell;
- chemin retourné par `pwd`/`Get-Location`;
- version Terraform et provider;
- adresse de ressource concernée;
- message d'erreur expurgé.

Ne communiquez jamais `terraform.tfvars`, un PAT, une clé privée, un state ou la configuration Snowflake complète.
