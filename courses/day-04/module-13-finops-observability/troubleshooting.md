# Runbook — M13 FinOps

> [<- Jour 4](../README.md) · [<- Module precedent](../module-12-capstone/lab.md) · **Module 13** · [Module suivant ->](../module-14-data-products/lab.md)

## `dbt debug` échoue

1. Exécuter `dbt debug --config-dir`.
2. Vérifier que le profil s'appelle `finops`.
3. Tester séparément compte, utilisateur, rôle, warehouse et database.
4. Ne jamais copier le profil réel dans le dépôt.

## `ACCOUNT_USAGE` est vide

1. Vérifier l'édition Snowflake et les privilèges.
2. Élargir la fenêtre temporelle.
3. Attendre 1 à 3 heures après la création de l'activité.
4. Ne pas réduire les tests de qualité pour masquer la latence.

## Privilèges insuffisants

```sql
SHOW GRANTS TO ROLE GOVERNANCE;
SHOW GRANTS ON DATABASE SNOWFLAKE;
```

En production, corriger le module RBAC et repasser par le pipeline plutôt que d'accorder durablement `ACCOUNTADMIN`.

## Récupération

Les modèles dbt sont idempotents. Après correction de l'identité ou des privilèges, relancer `dbt build --select +<modele>` puis le build complet.

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
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M13
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M13
```

Remplacez `M13` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

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
   pwd  # doit afficher labs/m13-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m13-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.

