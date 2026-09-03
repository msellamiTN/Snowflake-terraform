# Dépannage — M12 : Capstone

> [<- Jour 4](../README.md) · [<- Module precedent](../module-11-rbac/lab.md) · **Module 12** · [Module suivant ->](../module-13-finops-observability/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` montre 50+ ressources à créer | Premier run, aucun state | Attendu au premier apply. Exécuter `terraform apply`. |
| `Error: module source not found` | Chemin ou URL statique incorrecte | Corriger le littéral `source` puis relancer `terraform init -upgrade` |
| `dbt deps` échoue : `package not found` | Nom ou version de package incorrect | Vérifier que `packages.yml` a `getsnowflake/snowflake` version `4.6.0` et `dbt-utils` version `1.3.3` |
| `dbt build` échoue : `database not found` | Base FinOps non créée | Créer `DB_FINOPS_DEV` dans Snowflake ou laisser dbt la créer (nécessite le privilège `CREATE DATABASE`) |
| `dbt build` échoue : `ACCOUNT_USAGE access denied` | Le rôle manque `GOVERNANCE` ou `ACCOUNTADMIN` | Utiliser le rôle `ACCOUNTADMIN` dans le profil dbt |
| `dbt test` échoue : `accepted_values` | Statut de risque avec valeur inattendue | Vérifier `stg_resource_monitors` pour les cas limites ; ajuster `accepted_values` si nécessaire |
| `terraform plan -detailed-exitcode` retourne 2 | Drift détecté | Exécuter `terraform apply` pour réconcilier, ou investiguer les changements manuels |
| `snow sql` échoue : `connection not found` | Profil non configuré | Copier `profiles.yml.example` vers `~/.dbt/profiles.yml` et remplir les identifiants |
| `Error: data_mesh_spokes not configured` | Variable spokes vide | Ajouter des définitions de spokes dans `terraform.tfvars` ou laisser vide pour la plateforme de base |
| `terraform state list` montre des ressources inattendues | State d'un module précédent | Exécuter `terraform destroy` sur les anciennes ressources ou utiliser une clé de state propre |
| `dbt build` échoue : `ACCOUNT_USAGE latency` | Les vues ont 1-2h de latence | Attendre que les données se peuplent ; utiliser `--vars 'start_date: "2025-01-01"'` pour les données historiques |

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
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M12
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M12
```

Remplacez `M12` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

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
   pwd  # doit afficher labs/m12-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m12-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.

