# Dépannage — M11 : RBAC & Future Grants

> [<- Jour 4](../README.md) · [<- Jour 3](../../day-03/README.md) · **Module 11** · [Module suivant ->](../module-12-capstone/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `SHOW ROLES` affiche d'anciens noms de rôles | Rôles non renommés | Utiliser des blocs `moved {}` ou `terraform state mv` pour un renommage sécurisé |
| `Error: role already exists` | Rôle créé hors Terraform | Importer : `terraform import snowflake_account_role.this RL_DATA_ENGINEER_DEV` |
| Future grant échoue : `insufficient privileges` | Le rôle manque `MANAGE GRANTS` | Utiliser `SECURITYADMIN` ou `ACCOUNTADMIN` pour les opérations de grant |
| `SHOW FUTURE GRANTS` retourne vide | Future grants non appliqués | Exécuter `terraform apply` et vérifier les ressources `snowflake_grant_privileges_to_account_role.future` |
| `Error: duplicate grant` | Même privilège accordé deux fois | Vérifier la map `role_definitions` pour des grants chevauchants |
| Hiérarchie de rôles incorrecte : `parent_role` introuvable | Faute de frappe dans la clé `parent_role` | S'assurer que `parent_role` dans `role_definitions` correspond à une clé ou un nom de rôle système |
| `terraform plan` montre tous les rôles "to create" | `role_definitions` a changé | Utiliser des blocs `moved` ou importer les rôles existants avant d'appliquer |
| Association de tag échoue : `tag not found` | Tag pas encore créé | Ajouter `depends_on = [module.landing_zone]` aux ressources d'association de tags |
| `Error: cannot grant to self` | Rôle accordé à lui-même | Vérifier que `parent_role` ne crée pas de dépendance circulaire |

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
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M11
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M11
```

Remplacez `M11` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

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
   pwd  # doit afficher labs/m11-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m11-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.

