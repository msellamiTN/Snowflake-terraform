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

