# Dépannage — M5 : Modules & Git Registry

> [<- Jour 2](../README.md) · [<- Jour 1](../../day-01/README.md) · **Module 05** · [Module suivant ->](../module-06-dynamic-logic/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `terraform init` échoue : `module not found` | Mauvais chemin source | Vérifier le chemin relatif : `../../../03-day2-modules/modules/landing-zone` |
| `terraform init` échoue : `git clone failed` | URL Git incorrecte ou pas d'accès | Vérifier le format URL : `git::https://...` et que le PAT ADO a un accès en lecture |
| `terraform init` échoue : `ref not found` | Le tag n'existe pas | Vérifier que le tag existe : `git tag -l 'v*'` dans le dépôt de modules |
| `terraform plan` échoue : `unsupported argument` | Incompatibilité de version de module | S'assurer que la version du module correspond aux inputs attendus ; vérifier le CHANGELOG |
| `terraform plan` montre 0 ressource | Module non appelé | Ajouter le bloc `module "landing_zone" { source = ... }` |
| `Error: duplicate resource` | Le module crée une ressource qui existe aussi à la racine | Supprimer le doublon de la racine ou utiliser un bloc `moved` |
| `tflint` avertit sur la source du module | Tflint non initialisé | Exécuter `tflint --init` avant `tflint --recursive` |
| `terraform fmt -check` échoue dans le module | Code du module non formaté | Exécuter `terraform fmt` dans le répertoire du module |

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

