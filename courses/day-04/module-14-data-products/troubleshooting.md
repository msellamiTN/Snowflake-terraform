# Runbook — M14 Data Products

> [<- Jour 4](../README.md) · [<- Module precedent](../module-13-finops-observability/lab.md) · **Module 14** · [Fin ->](../../README.md)

## Le module ne trouve pas le warehouse

M14 consomme `WH_ETL_{ENV}` créé par la Landing Zone. Déployez M12 avant M14 et vérifiez l'environnement.

## Snow CLI utilise le mauvais contexte

```sql
SELECT CURRENT_ACCOUNT(), CURRENT_USER(), CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_WAREHOUSE();
```

Passez toujours `--database` et `--warehouse`. Utilisez une connexion Snow CLI dédiée par environnement.

## Le rôle lecteur ne voit pas une table existante

Les Future Grants couvrent les futurs objets, pas les tables antérieures à leur création. Corrigez les grants existants via Terraform, puis conservez les Future Grants pour la suite.

## Récupération SQL

Les fichiers utilisent `IF NOT EXISTS` et `CREATE OR REPLACE VIEW`. Corrigez le contexte, rejouez le fichier, exécutez les tests puis contrôlez `terraform plan`.

## Rollback

Revenez au commit SQL précédent et redéployez. Ne supprimez pas la database avec Terraform pour annuler une évolution de vue.

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
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M14
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M14
```

Remplacez `M14` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

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
   pwd  # doit afficher labs/m14-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m14-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.

