# Installer Git avec PowerShell et support OpenSSL

# Option 1 : installation via winget (Git for Windows inclut OpenSSL)
winget install --id Git.Git -e --source winget

# Redémarrer PowerShell, puis cloner le projet
# https://github.com/msellamitn/snowflake-terraform.git
git clone https://github.com/msellamitn/snowflake-terraform.git
cd snowflake-terraform

# Exécuter le script d'installation du lab
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Install-LabEnvironment.ps1

