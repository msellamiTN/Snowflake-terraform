# Dépannage — M8 : Stratégies d'environnements

> [<- Jour 2](../README.md) · [<- Module precedent](../module-07-cicd-pipeline/lab.md) · **Module 08** · [Jour 3 ->](../../day-03/README.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` pour UAT ou PROD montre les ressources DEV | Mauvais fichier de state | Vérifier les clés `training/APP01/uat/terraform.tfstate` et `training/APP01/prod/terraform.tfstate` ; remplacer `APP01` par le préfixe apprenant. |
| `Error: database already exists` | Deux environnements partagent le même nom de base | S'assurer que la variable `environment` diffère : `DEV`, `UAT` ou `PROD`. |
| `terraform init` télécharge le même state pour deux environnements | Même clé backend | Chaque racine doit avoir sa clé `training/APP01/<env>/terraform.tfstate` unique et `use_azuread_auth = true`. |
| `AuthenticationFailed` ou Azure CLI demande une account key | Authentification data-plane implicite | Se connecter avec `Learner-Login`, vérifier le rôle `Storage Blob Data Contributor` et ajouter `--auth-mode login` aux commandes `az storage`. |
| La liste des blobs est vide ou inaccessible | Mauvais préfixe APP ou droits RBAC non propagés | Utiliser `--prefix "training/APP01/" --auth-mode login`, vérifier le préfixe apprenant et attendre quelques minutes après l'attribution RBAC. |
| Confusion avec `terraform workspace` | Workspaces non utilisés dans ce cours | Utiliser des répertoires séparés (`environments/dev`, `environments/uat`, `environments/prod`). |
| `deployment_mode` non défini | Variable manquante dans tfvars | Ajouter `deployment_mode = "training"` dans `terraform.tfvars`. |
| `terraform plan -var="deployment_mode=production"` échoue | Clé privée non configurée | Définir `private_key_path` dans tfvars ou utiliser `deployment_mode = "training"`. |
| Erreur de grant cross-environnement | Rôle d'un autre environnement référencé | Chaque environnement crée ses propres rôles avec le suffixe `_DEV`, `_UAT` ou `_PROD`. |

---

## Execution policy PowerShell

**Symptome :**

```text
Impossible de charger le fichier ...ps1, car l'execution de scripts est desactivee.
```

**Cause :** La politique d'execution PowerShell est reglee sur `Restricted`.

**Correction :**

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

> `RemoteSigned` autorise les scripts locaux. C'est le parametre standard pour un poste de formation.

**Alternative ponctuelle :**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\<script-name>.ps1
```

---

## ❌ `Object already exists` in Snowflake

**Symptom** : `terraform plan` ou `terraform apply` échoue avec :

```
Error: Object does not exist or not authorized
```

ou

```
Error: Object already exists
```

**Cause** : Une exécution précédente du lab a créé des ressources qui n'ont pas été nettoyées.

**Fix** :

🪟 **Windows (PowerShell)** :

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M08
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M08
```

Remplacez `M08` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

> 💡 **Note** : `Reset-Lab.ps1` ne détruit que les ressources du lab spécifié. Les autres labs ne sont pas affectés.

---

## ❌ `Duplicate output/variable/resource definition`

**Symptom** : `terraform validate` ou `terraform plan` échoue avec :

```
Error: Duplicate output definition
```

ou

```
Error: Duplicate variable definition
```

**Cause** : Vous avez ajouté un bloc qui existe déjà, ou vous travaillez dans le mauvais répertoire.

**Fix** :

1. Vérifiez que vous êtes dans le bon répertoire :

   ```powershell
   pwd  # doit afficher labs/m08-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m08-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.
