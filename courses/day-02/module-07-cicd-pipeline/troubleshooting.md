# Dépannage — M7 : Pipeline CI/CD

> [<- Jour 2](../README.md) · [<- Module precedent](../module-06-dynamic-logic/lab.md) · **Module 07** · [Module suivant ->](../module-08-environments/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| Pipeline non déclenché sur PR | Filtre de chemin incorrect | Vérifier que `paths.include` contient `project/05-capstone/**`, `project/03-day2-modules/modules/**` et `azure-pipelines.yml` |
| `terraform fmt -check` échoue en CI | Code local non formaté | Exécuter `terraform fmt -recursive` localement et committer |
| `tflint` échoue en CI | Tflint non initialisé | Ajouter l'étape `tflint --init` avant `tflint --recursive` ; utiliser `.tflint.hcl` adapté |
| `terraform init` échoue : `subscription id not specified` | `ARM_SUBSCRIPTION_ID` non renseigné | Récupérer l'ID depuis `az account show --query id -otsv` et l'exporter en variable |
| `terraform init` échoue : `AuthorizationFailed` sur storage | Le SP WIF manque de rôles | Ajouter `Reader`, `Storage Blob Data Contributor` et `Storage Account Key Operator Service Role` sur le compte de stockage |
| `terraform plan` échoue : `ARM_* not set` | Variables ADO non configurées | Utiliser WIF (`ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_OIDC_TOKEN`) ou variables secrètes `ARM_*` |
| `terraform apply` échoue : `state lock` | Run précédent a laissé un verrou | Ajouter une étape `terraform force-unlock` ou attendre l'expiration du lease |
| Artefact `tfplan` introuvable dans apply | Stage Plan non exécuté sur `main` | S'assurer que la condition du stage Plan s'exécute aussi sur `main`, et que `Apply` dépend de `Plan` |
| `Install Python` échoue dans `Audit` | `UsePythonVersion` non supporté sur agent auto-hébergé | Supprimer le stage `dbt/FinOps` pour ne conserver que le `Drift Check` |
| Erreur de syntaxe matrice ADO | Expression de template incorrecte | Utiliser `strategy.matrix` avec la variable `ROOT` par job |

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
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M07
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M07
```

Remplacez `M07` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

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
   pwd  # doit afficher labs/m07-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m07-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.

