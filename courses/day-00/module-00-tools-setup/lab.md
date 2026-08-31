> ⚠️ **Module déprécié** — ce contenu est conservé à titre de référence. Utilisez le nouveau lab fusionné : [M0 — Day 0](../module-00-day0-setup/lab.md).

# Atelier 0 — Installation des outils (prérequis)

**Durée :** 45 min
**Objectif :** Disposer de tous les outils installés et vérifiés sur le poste Windows avant d'aborder la configuration Snowflake et Terraform.

> Ce module est le **prérequis** du module [M0 — Préparation de l'environnement](../module-00-environment-pre-setup/lab.md) qui couvre la génération de clés RSA, l'authentification Snowflake JWT et la configuration Terraform.

---

## Objectifs

À la fin de cet atelier, vous serez capable de :

- Installer Git for Windows et OpenSSL
- Cloner le repository du cours
- Configurer PowerShell pour exécuter les scripts du lab
- Installer automatiquement tous les outils nécessaires via `Install-Tools.ps1`
- Vérifier l'installation de chaque outil
- Diagnostiquer les problèmes de PATH

## Architecture de l'environnement

```text
Windows
│
├── Git for Windows
│   ├── Git
│   └── OpenSSL
│
├── Terraform 1.14.5
│
├── Python 3.12
│   └── Snowflake CLI
│
├── Azure CLI
│
├── TFLint 0.50.0
│
└── Visual Studio Code
    │
    └── snowflake-terraform
```

---

## 1. Préparer PowerShell

### 1.1 Ouvrir PowerShell

Ouvrez : **Start → Windows PowerShell → Run as Administrator**

### 1.2 Vérifier PowerShell

```powershell
$PSVersionTable.PSVersion
```

Résultat attendu :

```text
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      ...
```

> Le lab cible Windows PowerShell 5.1.

---

## 2. Vérifier l'architecture Windows

Terraform et TFLint utilisent les binaires Windows AMD64.

```powershell
[Environment]::Is64BitOperatingSystem
# Attendu : True

$env:PROCESSOR_ARCHITECTURE
# Attendu : AMD64
```

---

## 3. Vérifier WinGet

```powershell
winget --version
# Attendu : v1.x.x
```

> Si winget est disponible, nous l'utiliserons pour installer Git.

---

## 4. Installer Git for Windows

Git for Windows fournit également les composants OpenSSL utilisés dans l'environnement du lab.

```powershell
winget install --id Git.Git -e --source winget
```

Attendez la fin de l'installation. Vous devez obtenir :

```text
Successfully installed
```

---

## 5. Redémarrer PowerShell

> **Important :** Fermez complètement PowerShell et ouvrez une nouvelle fenêtre.
> Les nouveaux programmes et modifications du PATH ne sont pas automatiquement disponibles dans les anciennes sessions.

---

## 6. Vérifier Git et OpenSSL

```powershell
git --version
# Exemple : git version 2.55.0.windows.3

where.exe git
# Exemple : C:\Program Files\Git\cmd\git.exe

openssl version
# Exemple : OpenSSL 3.5.7 ...

where.exe openssl
# Exemple : C:\Program Files\Git\mingw64\bin\openssl.exe
```

### Dépannage OpenSSL

Si `openssl version` retourne `openssl : The term 'openssl' is not recognized` :

```powershell
Test-Path "C:\Program Files\Git\mingw64\bin\openssl.exe"
# Attendu : True

# Ajoutez temporairement le chemin à la session
$env:PATH = "C:\Program Files\Git\mingw64\bin;$env:PATH"
openssl version
```

---

## 7. Configurer Git

```powershell
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"

# Vérifiez
git config --global user.name
git config --global user.email
```

---

## 8. Cloner le repository

```powershell
# Créer le répertoire de formation
cd $HOME
New-Item -ItemType Directory -Path "$HOME\training" -Force
cd "$HOME\training"

# Cloner
git clone https://github.com/msellamitn/snowflake-terraform.git

# Entrer dans le projet
cd snowflake-terraform

# Vérifier
git status
git remote -v
# Attendu : origin  https://github.com/msellamitn/snowflake-terraform.git
```

---

## 9. Autoriser les scripts PowerShell

Nous ne modifions pas la politique globale de Windows. Autorisez uniquement les scripts dans la session courante :

```powershell
Set-ExecutionPolicy -Scope Process Bypass

Get-ExecutionPolicy
# Attendu : Bypass
```

---

## 10. Installer l'environnement complet

Le script `Install-Tools.ps1` installe et vérifie les 8 outils requis (ordre du script) :

```powershell
# Vérifiez que le script existe
Test-Path .\scripts\Install-Tools.ps1
# Attendu : True

# Lancez l'installation
.\scripts\Install-Tools.ps1
```

Le script est **idempotent** : les outils déjà conformes sont conservés. Il installe ou vérifie :

| # | Outil | Version | Méthode |
|---|---|---|---|
| 1 | Terraform | 1.14.5 | ZIP → `C:\tools\tf-bin` |
| 2 | Python | 3.12 | winget ou installer |
| 3 | Snowflake CLI | latest | `pip install snowflake-cli` |
| 4 | Git | latest | winget ou installer |
| 5 | OpenSSL | (via Git) | détection Git\mingw64\bin |
| 6 | VS Code | latest | winget ou installer + extensions |
| 7 | Azure CLI | latest | winget ou MSI |
| 8 | TFLint | 0.50.0 | ZIP → `C:\tools\tflint-bin` |

> 📌 Le script installe automatiquement les extensions VS Code : `HashiCorp.terraform`, `ms-azuretools.vscode-azureterraform`, `ms-python.python`, `redhat.vscode-yaml`, `shd101wyy.markdown-preview-enhanced`.

À la fin, recherchez :

```text
[OK] Terraform
[OK] Python
[OK] Snowflake CLI
[OK] Git
[OK] OpenSSL
[OK] VS Code
[OK] Azure CLI
[OK] TFLint
```

Vous devez obtenir :

```text
INSTALLATION TERMINEE AVEC SUCCES
```

---

## 11. Redémarrer PowerShell

> **Très important :** Fermez PowerShell, ouvrez une nouvelle fenêtre, puis revenez dans le projet :

```powershell
cd $HOME\training\snowflake-terraform
```

---

## 12. Vérification manuelle des outils

Même si le script automatique passe, effectuons une validation manuelle :

```powershell
# Terraform
terraform version
# Attendu : Terraform v1.14.5

# Python
python --version
# Attendu : Python 3.12.x

# Snowflake CLI
snow --version
# Attendu : Snowflake CLI 3.x.x

# Git
git --version

# OpenSSL
openssl version

# VS Code
code --version

# Azure CLI
az version

# TFLint
tflint --version
# Attendu : TFLint version 0.50.0
```

### Vérification globale en une commande

```powershell
$tools = @("git", "openssl", "terraform", "python", "snow", "az", "tflint", "code")
foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "[OK] $tool" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $tool" -ForegroundColor Red
    }
}
```

Résultat attendu :

```text
[OK] git
[OK] openssl
[OK] terraform
[OK] python
[OK] snow
[OK] az
[OK] tflint
[OK] code
```

---

## 13. Vérifier Azure CLI

```powershell
az account show
```

Si aucune session n'est disponible :

```powershell
az login
az account show
az account list -o table
```

Identifiez l'abonnement fourni pour la formation, puis :

```powershell
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
az account show -o table
```

---

## 14. Initialiser et valider Terraform

```powershell
terraform init
# Attendu : Terraform has been successfully initialized!

terraform validate
# Attendu : Success! The configuration is valid.

terraform fmt -recursive
terraform fmt -recursive -check
```

---

## 15. Vérifier TFLint

```powershell
# Si .tflint.hcl existe
tflint --init
tflint
```

---

## 16. Ouvrir le projet dans VS Code

```powershell
code .
```

Extensions recommandées :

```powershell
code --list-extensions
```

- `HashiCorp.terraform`
- `ms-azuretools.vscode-azureterraform`
- `ms-python.python`
- `redhat.vscode-yaml`
- `shd101wyy.markdown-preview-enhanced`

---

## 17. Diagnostic PATH

Si une commande fonctionne dans le script mais pas directement après l'installation :

```powershell
$env:PATH -split ";"
```

Cherchez notamment :

```text
C:\tools\tf-bin
C:\tools\tflint-bin
```

Pour le PATH utilisateur permanent :

```powershell
[Environment]::GetEnvironmentVariable("PATH","User") -split ";"
```

### Diagnostic direct

```powershell
# Terraform
C:\tools\tf-bin\terraform.exe version

# TFLint
C:\tools\tflint-bin\tflint.exe --version
```

Si l'exécutable fonctionne directement mais pas `terraform` / `tflint`, le problème est uniquement le PATH.

---

## 18. Procédure de récupération après installation

Si un outil affiche `The term 'terraform' is not recognized` :

1. Fermez PowerShell
2. Ouvrez une nouvelle session
3. Testez : `terraform version`
4. Si le problème persiste : `where.exe terraform`
5. Vérifiez le fichier : `Test-Path C:\tools\tf-bin\terraform.exe`
6. Refaites la même procédure avec : `where.exe python`, `where.exe snow`, `where.exe openssl`, `where.exe az`, `where.exe tflint`

---

## ✅ Critères de réussite

L'atelier est terminé lorsque vous obtenez :

```text
[OK] Terraform
[OK] Python
[OK] Snowflake CLI
[OK] Git
[OK] OpenSSL
[OK] VS Code
[OK] Azure CLI
[OK] TFLint
```

Et :

```text
Success! The configuration is valid.
```

---

## Quick Start

Pour une nouvelle machine Windows, la procédure minimale est :

```powershell
# 1. Installer Git + OpenSSL
winget install --id Git.Git -e --source winget

# 2. Fermer et rouvrir PowerShell

# 3. Vérifier Git
git --version
openssl version

# 4. Cloner le projet
cd $HOME
New-Item -ItemType Directory -Path "$HOME\training" -Force
cd "$HOME\training"
git clone https://github.com/msellamitn/snowflake-terraform.git
cd snowflake-terraform

# 5. Autoriser les scripts pour cette session
Set-ExecutionPolicy -Scope Process Bypass

# 6. Installer l'environnement
.\scripts\Install-Tools.ps1

# 7. Fermer et rouvrir PowerShell
cd $HOME\training\snowflake-terraform

# 8. Initialiser et valider Terraform
terraform init
terraform validate

# 9. Ouvrir VS Code
code .
```

---

## Livrable de l'atelier

À la fin de l'atelier, votre poste doit être dans cet état :

```text
snowflake-terraform/
│
├── scripts/
│   └── Install-Tools.ps1
│
├── Terraform configuration
├── Snowflake configuration
├── Documentation
└── Git repository
```

> ✅ **Votre environnement est prêt.** Passez au module [M0 — Préparation de l'environnement](../module-00-environment-pre-setup/lab.md) pour configurer l'authentification Snowflake JWT et Terraform.
