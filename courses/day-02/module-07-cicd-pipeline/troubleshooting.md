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

