# Dépannage — M6 : Logique dynamique & for_each

> [<- Jour 2](../README.md) · [<- Module precedent](../module-05-modules/lab.md) · **Module 06** · [Module suivant ->](../module-07-cicd-pipeline/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform plan` échoue : `invalid for_each argument` | for_each sur un type non-map/list | S'assurer que `for_each` utilise `var.schemas` (set) ou `var.warehouses` (map) |
| `Error: duplicate key in for_each` | Entrées en double dans la map/set d'entrée | Supprimer les doublons de la variable `schemas` ou `warehouses` |
| `flatten()` produit une structure incorrecte | Flatten imbriqué pas assez profond | Utiliser le pattern `flatten([... for ... : [ for ... : { ... } ]])` |
| `terraform plan` montre 0 schéma | Variable `schemas` vide | Définir `schemas = ["RAW", "SILVER", "GOLD"]` dans tfvars |
| `Error: Invalid object` pour warehouse | Attributs requis manquants | S'assurer que chaque warehouse a au moins l'attribut `size` |
| `snowflake_grant_account_role` échoue : `role not found` | Rôle pas encore créé | Ajouter `depends_on = [snowflake_account_role.this]` |
| `for_each` sur `var.users` échoue | La map users a un mauvais type | S'assurer que `users` est `map(object({roles = list(string), ...}))` |

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

