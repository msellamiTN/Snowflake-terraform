# Dépannage — M4 : Variables, Outputs & Lifecycle

> [<- Jour 1](../README.md) · [<- Module precedent](../module-03-import-brownfield/lab.md) · **Module 4** · [Jour 2 ->](../../day-02/README.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform validate` échoue : `Invalid value for variable` | Validation de variable échouée | Vérifier le bloc `validation` dans `variables.tf` et s'assurer que l'entrée correspond aux valeurs autorisées |
| `terraform plan` échoue : `Required variable not set` | Variable requise manquante | Fournir via `-var`, `-var-file`, ou `terraform.tfvars` |
| `terraform output` retourne vide | Aucun output défini ou state vide | Ajouter des blocs `output` dans `outputs.tf` et exécuter `terraform apply` |
| `prevent_destroy` bloque une destruction légitime | Protection lifecycle activée | Retirer `prevent_destroy` ou mettre à `false` temporairement (approbation formateur) |
| `depends_on` ne fonctionne pas | Mauvaise référence de ressource | S'assurer que `depends_on` référence des adresses de ressources, pas des noms de variables |
| `terraform plan -var-file` échoue : `file not found` | Mauvais chemin vers tfvars | Vérifier le chemin : `environments/dev.tfvars` relatif à la racine du module |
| `Error: Invalid type` pour une variable | Incompatibilité de type | S'assurer que le type de variable correspond à l'entrée (ex. `list(string)` pas `string`) |
| `terraform fmt -check` échoue | Code non formaté | Exécuter `terraform fmt` pour formater automatiquement |

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
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M04
```

🐧 **Linux/macOS (Bash)** :

```bash
cd "$HOME/Data2AI-Labs/data-platform"
./scripts/reset-lab.sh --learner-prefix APP01 --lab M04
```

Remplacez `M04` par le numéro du lab (M01, M05, etc.) et `APP01` par votre préfixe.

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
   pwd  # doit afficher labs/m04-name/
   ```

2. Si vous êtes dans `environments/dev/`, vous êtes dans l'ancienne structure. Déplacez-vous vers `labs/m04-name/`.

3. Si le fichier contient des doublons, **remplacez tout le contenu** au lieu d'ajouter à la fin.

