# Étape 1 — Installer et vérifier les outils

**Durée cible : 30 minutes**

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Résultat attendu

À la fin de cette étape, ces trois commandes obligatoires fonctionnent :

```text
git --version
terraform version
snow --version
```

VS Code est recommandé mais facultatif. OpenSSL, Azure CLI, AWS CLI, Google Cloud CLI, TFLint et dbt ne sont pas requis pour terminer le Jour 0.

## 1. Choisir votre piste

- [Windows et PowerShell](#piste-windows)
- [Linux et Bash](#piste-linux)
- [macOS](#piste-macos)

Suivez une seule piste. Rejoignez ensuite [la vérification commune](#5-vérification-commune).

---

## Piste Windows

### 2W.1 — Ouvrir PowerShell sans privilège administrateur

Ouvrez PowerShell puis vérifiez :

```powershell
$PSVersionTable.PSVersion
[Environment]::Is64BitOperatingSystem
```

Attendu : PowerShell 5.1 ou 7 et `True` pour un poste 64 bits.

> N’utilisez une session administrateur que si la politique de votre poste l’exige pour une installation précise.

### 2W.2 — Vérifier les outils avant d’installer

```powershell
Get-Command git -ErrorAction SilentlyContinue
Get-Command terraform -ErrorAction SilentlyContinue
Get-Command snow -ErrorAction SilentlyContinue
Get-Command code -ErrorAction SilentlyContinue
```

Pour chaque commande qui retourne un chemin, l’outil est déjà présent. Ne le réinstallez pas.

### 2W.3 — Installer Git si nécessaire

Si `winget` est disponible :

```powershell
winget --version
winget install --id Git.Git -e --source winget
```

Fermez complètement PowerShell, ouvrez une nouvelle fenêtre, puis exécutez :

```powershell
git --version
```

### 2W.4 — Installer Terraform si nécessaire

Utilisez l’une des méthodes suivantes :

1. le package approuvé par votre entreprise;
2. l’installation HashiCorp officielle;
3. le script `scripts/Install-LabEnvironment.ps1` uniquement sur un poste de formation Windows autorisé.

Après installation, ouvrez un nouveau terminal :

```powershell
terraform version
where.exe terraform
```

Attendu : Terraform 1.14.x et un chemin unique compréhensible.

### 2W.5 — Installer Snowflake CLI si nécessaire

Utilisez l’installateur ou la procédure officielle Snowflake adaptée à Windows. N’exécutez pas un `pip install` global sur un poste partagé ou d’entreprise.

Vérifiez dans un nouveau terminal :

```powershell
snow --version
where.exe snow
```

### 2W.6 — Installer un éditeur

VS Code est recommandé :

```powershell
code --version
```

Si `code` n’est pas disponible mais que votre éditeur peut créer des fichiers texte UTF-8, vous pouvez continuer.

---

## Piste Linux

### 2L.1 — Identifier votre distribution

```bash
uname -a
cat /etc/os-release
```

### 2L.2 — Vérifier les outils existants

```bash
command -v git || true
command -v terraform || true
command -v snow || true
command -v code || true
```

### 2L.3 — Installer Git

Utilisez le gestionnaire de paquets de votre distribution. Exemple Debian/Ubuntu :

```bash
sudo apt-get update
sudo apt-get install -y git
```

Si vous n’avez pas les droits `sudo`, demandez le package approuvé à votre administrateur. Ne contournez pas la politique du poste.

### 2L.4 — Installer Terraform

Utilisez le dépôt HashiCorp officiel ou le gestionnaire de versions approuvé par votre entreprise. Vérifiez ensuite :

```bash
terraform version
command -v terraform
```

### 2L.5 — Installer Snowflake CLI

Utilisez la procédure officielle Snowflake. Si votre organisation utilise Python pour cette installation, créez un environnement isolé ou utilisez l’outil de packaging approuvé; n’installez pas dans le Python système global.

```bash
snow --version
command -v snow
```

---

## Piste macOS

### 2M.1 — Vérifier les outils

```bash
uname -m
command -v git || true
command -v terraform || true
command -v snow || true
```

### 2M.2 — Installer les outils manquants

Utilisez Homebrew si son usage est autorisé sur votre poste :

```bash
brew --version
brew install git
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Installez Snowflake CLI avec la procédure officielle Snowflake, dans un environnement isolé si elle s’appuie sur Python.

Ouvrez un nouveau terminal puis vérifiez :

```bash
git --version
terraform version
snow --version
```

---

## 3. Obtenir le dépôt de formation

### Si le dépôt est déjà ouvert

Ne le clonez pas une deuxième fois. Depuis le terminal intégré :

```text
git rev-parse --show-toplevel
git status --short
```

Le premier résultat doit se terminer par `Snowflake-terraform`. Ne supprimez pas les modifications affichées.

### Si le dépôt n’est pas encore présent

Demandez au formateur l’URL exacte et le dossier de destination. Ensuite :

```text
git clone <URL_FOURNIE_PAR_LE_FORMATEUR>
cd Snowflake-terraform
```

Le support ne force pas une URL personnelle ou une branche particulière.

## 4. Vérifier la protection locale

Depuis la racine du dépôt :

```text
git check-ignore .env
git check-ignore secrets/probe.token
```

Attendu :

```text
.env
secrets/probe.token
```

Si une ligne manque, ne créez encore aucun credential. Ouvrez le troubleshooting du lab principal.

## 5. Vérification commune

### Windows

```powershell
$required = @('git', 'terraform', 'snow')
foreach ($tool in $required) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "[PASS] $tool"
    } else {
        Write-Host "[FAIL] $tool"
    }
}
```

### Linux/macOS

```bash
for tool in git terraform snow; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '[PASS] %s\n' "$tool"
  else
    printf '[FAIL] %s\n' "$tool"
  fi
done
```

Critère : trois lignes `PASS`.

## 6. Préflight local

Cette commande ne se connecte pas à Snowflake et ne modifie rien.

### Windows

```powershell
.\scripts\Setup-Day0.ps1 -AccessScenario SANDBOX -SkipSnowflake
```

### Linux/macOS

```bash
bash ./scripts/setup-day0.sh --scenario SANDBOX --skip-snowflake
```

À ce stade, `.env local` peut encore être en `FAIL`; il sera créé dans l’étape suivante. Git, Terraform, Snowflake CLI, `.env.example` et `.gitignore` doivent être en `PASS`.

## Checkpoint

- [ ] Git répond;
- [ ] Terraform 1.14.x répond;
- [ ] Snowflake CLI répond;
- [ ] vous êtes à la racine du bon dépôt;
- [ ] `.env` et `secrets/` sont ignorés;
- [ ] vous savez quel éditeur utiliser.

## Étape suivante

1. Lisez le [cours court : configuration et secrets](../module-00-day0-setup/course.md).
2. Continuez avec le [lab principal Day 0](../module-00-day0-setup/lab.md).

En cas d’échec, utilisez le [troubleshooting Day 0](../module-00-day0-setup/troubleshooting.md) et rejouez uniquement la vérification concernée.
