# Module — Installation des outils

**Durée :** 45 min

Ce module couvre l'installation et la vérification de tous les outils requis pour la formation Terraform & Snowflake.

## Quick Start

```powershell
# 1. Installer Git
winget install --id Git.Git -e --source winget

# 2. Fermer et rouvrir PowerShell

# 3. Cloner le projet
cd $HOME
New-Item -ItemType Directory -Path "$HOME\training" -Force
cd "$HOME\training"
git clone https://github.com/msellamitn/snowflake-terraform.git
cd snowflake-terraform

# 4. Installer tous les outils
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Install-Tools.ps1
```

## Contenu

| Fichier | Description |
|---------|-------------|
| [lab.md](lab.md) | Atelier complet : installation et vérification des 8 outils |

## Outils installés

1. Terraform 1.14.5
2. Python 3.12 + Snowflake CLI
3. Git + OpenSSL
4. VS Code
5. Azure CLI
6. TFLint 0.50.0

## Suite

Après ce module, passez à [M0 — Préparation de l'environnement](../module-00-environment-pre-setup/lab.md) pour configurer l'authentification Snowflake JWT et Terraform.