# 🧪 Lab M00 — Préparer votre environnement de formation

> [<- Jour 0](../README.md) · **M00 Setup** · [Jour 1 ->](../../day-01/module-01-iac-workflow/lab.md)

| Élément | Valeur |
|---|---|
| **Durée** | 1 h 30 |
| **Piste** | `[CORE]` |
| **Workspace** | `$HOME/Data2AI-Labs/data-platform` (le clone du projet type) |
| **Coût Estimé** | $0 (aucune ressource cloud créée) |
| **Certifications** | HashiCorp Terraform Associate · Snowflake SnowPro · Azure AZ-104 |
| **Cleanup** | Conservation obligatoire — base de tous les modules suivants |

---

## 🎯 1. Mission Métier & User Story

> **En tant que :** Cloud Data Engineer en formation
> **Je veux :** préparer et valider mon environnement de travail (toolchain, credentials, connexions)
> **Afin de :** garantir que tous les labs M01 à M14 s'exécutent sans friction technique

---

## 🏗️ 2. Architecture & Modèle Mental

```mermaid
flowchart LR
    DEV["🧑‍💻 Apprenant"] -->|"1. git clone"| REPO["📦 data-platform-starter"]
    REPO -->|"2. Install-Tools"| TOOLS["⚙️ Toolchain: Terraform, Snow CLI, Azure CLI, dbt"]
    REPO -->|"3. New-SnowflakeConnection"| SNOW["❄️ Snowflake CLI -c training"]
    REPO -->|"4. Learner-Login"| AZURE["☁️ Azure SP + Key Vault PAT"]
    TOOLS --> VERIFY["✅ Test-LabConnectivity: READY"]
    SNOW --> VERIFY
    AZURE --> VERIFY
```

---

## 🎯 3. Objectifs Pédagogiques Vérifiables

- ✅ le **projet type** est cloné sous `$HOME/Data2AI-Labs/data-platform`;
- ✅ Git, Terraform, Snowflake CLI, Azure CLI et dbt sont disponibles dans le terminal;
- ✅ la connexion Snowflake `training` répond à `snow sql -q 'SELECT 1' -c training`;
- ✅ Azure est authentifié via le service principal partagé;
- ✅ la connexion aux consoles web (Snowsight + Azure Portal) est confirmée;
- ✅ la validation finale affiche `Toolchain status: READY`.

---

## 🚀 4. Pre-Flight Diagnostic (Vérification Initiale)

> **Toutes les commandes s'exécutent depuis la racine du clone** (`$HOME/Data2AI-Labs/data-platform`).

### Si votre VM a des outils préinstallés (vérification rapide)

> `[IMPORTANT]` Si vous travaillez sur une **VM préconfigurée** (outils déjà installés
> par le formateur), commencez par vérifier l'installation existante **avant** de
> lancer l'installation. Le préflight est **non destructif** : il n'installe rien.

```powershell
# Vérification des outils uniquement (avant configuration .env / Azure / Snowflake)
.\scripts\Test-VMReadiness.ps1 -SkipConnectivity
```

**Résultat attendu si les outils sont corrects :**

```text
Status: READY
```

- ✅ Si tous les outils sont en `PASS` → **sautez l'étape 5.1** (installation) et passez directement à l'étape 5.2 (configuration `.env`).
- ❌ Si un ou plusieurs outils sont en `FAIL` → suivez l'étape 5.1 normale ci-dessous (`Install-Tools.ps1`), puis relancez le préflight.

Une fois `.env` configuré et `Learner-Login` exécuté, lancez le préflight complet :

```powershell
.\scripts\Test-VMReadiness.ps1 -LearnerPrefix APP01
```

> Remplacez `APP01` par votre préfixe. Le rapport consolidé est écrit dans
> `reports/vm-readiness.md`. Aucun secret n'y apparaît.

### Ordre d'exécution des scripts

> `[IMPORTANT]` L'ordre des scripts est important. Suivez cette séquence exacte.

| # | Script | Quand | Action |
|---|---|---|---|
| 0 | `Set-ExecutionPolicy` | Une seule fois | Autorise les scripts PowerShell (Windows) |
| 1 | `Install-Tools.ps1` | Une seule fois | Installe Terraform, Snow CLI, dbt, tflint |
| 2 | `New-SnowflakeConnection.ps1` | Une seule fois | Configure Snow CLI + écrit le PAT dans `secrets/snowflake_pat.txt` (fallback) |
| 3 | `Learner-Login.ps1` | **Chaque session** | Login Azure + récupère le PAT depuis Key Vault + set `TF_VAR_snowflake_token` |
| 4 | `Test-LabConnectivity.ps1` | Vérification | Valide tous les accès (Snowflake + Azure + Git + Terraform) |

```powershell
# 0. Autoriser les scripts (une seule fois, Windows seulement)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 1. Installer les outils (une seule fois)
.\scripts\Install-Tools.ps1

# 2. Configurer Snowflake (une seule fois)
.\scripts\New-SnowflakeConnection.ps1

# 3. Login Azure + variables Terraform (Chaque session)
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01

# 4. Vérifier tout
.\scripts\Test-LabConnectivity.ps1 -SkipDevOps
```

> `[IMPORTANT]` `Learner-Login.ps1` récupère le PAT depuis **Azure Key Vault**
> (secret partagé `SnowflakePAT`). Si Key Vault est inaccessible,
> il utilise `secrets/snowflake_pat.txt` comme fallback (créé par `New-SnowflakeConnection.ps1`).
> Sans cela, `terraform plan` vous demandera `var.snowflake_token` manuellement.

### Cloner le projet type (5 min)

Le projet type est le dépôt `data-platform-starter`. Il contient les scripts d'installation, la structure de gouvernance et les validateurs. **C'est votre racine de travail pour toute la formation.**

Le dépôt du projet type est : `https://github.com/msellamiTN/data-platform-starter.git`

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
New-Item -ItemType Directory -Path "$HOME\Data2AI-Labs" -Force | Out-Null
git clone https://github.com/msellamiTN/data-platform-starter.git "$HOME\Data2AI-Labs\data-platform"
cd "$HOME\Data2AI-Labs\data-platform"
```

> **IMPORTANT** Sous Windows, ne pas utiliser `~` (tilde) dans le chemin de clone.
> PowerShell ne l'interprete pas comme le dossier personnel. Utilisez `$HOME` entre guillemets.
> Si le repertoire contient des espaces (ex. `Formation Terraform`), encadrez toujours le chemin.
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
mkdir -p "$HOME/Data2AI-Labs"
git clone https://github.com/msellamiTN/data-platform-starter.git "$HOME/Data2AI-Labs/data-platform"
cd "$HOME/Data2AI-Labs/data-platform"
```
</details>

### Vérifier que les scripts sont présents

```bash
ls scripts/
```

✅ **Checkpoint 0 :**

```text
Install-Tools.ps1
install-tools.sh
New-SnowflakeConnection.ps1
new-snowflake-connection.sh
Learner-Login.ps1
learner-login.sh
Test-LabConnectivity.ps1
test-lab-connectivity.sh
validate.ps1
validate.sh
```

> À partir d'ici, **toutes les commandes s'exécutent depuis la racine du clone**.

> `[WINDOWS]` Si vous obtenez l'erreur `l'exécution de scripts est désactivée`,
> autorisez les scripts locaux une seule fois :
>
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```
>
> `RemoteSigned` est le paramètre standard pour un poste de formation.
> Il autorise les scripts locaux mais bloque les scripts téléchargés non signés.
>
> `[NOTE]` Si vous voyez le message *"ce paramétrage est remplacé par une stratégie
> définie dans un contexte plus spécifique"* et que votre stratégie actuelle est
> `Bypass`, **c'est normal et sans conséquence**. La VM de formation a déjà
> `Bypass` actif (qui autorise tout). La commande `Set-ExecutionPolicy` n'a aucun
> effet dans ce cas, mais vous n'en avez pas besoin — vos scripts fonctionneront.
> Vérifiez avec :
> ```powershell
> Get-ExecutionPolicy -List
> ```

---

## 📝 5. Étapes d'Implémentation Pas-à-Pas (80% Hands-On)

### 📝 Étape 5.1 — Installer et vérifier les outils (20 min)

Le Jour 0 est **automatise**. Vous executez les scripts qui se trouvent dans le clone, puis vous lisez le rapport.

- **Windows** : `scripts/Install-Tools.ps1`
- **Linux/macOS** : `scripts/install-tools.sh`

Les deux scripts ont le même contrat : mêmes versions, mêmes vérifications, même format de rapport.

#### Diagnostic initial

Executez le script en mode `Check` pour voir l'etat actuel sans rien installer :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check -ReportPath .\preflight
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
chmod +x scripts/install-tools.sh
./scripts/install-tools.sh --check --report-path ./preflight
```
</details>

**Checkpoint** : un rapport s'affiche et deux fichiers sont crees (`preflight.md` et `preflight.json`). Les outils deja installes sont en `PASS`, les autres en `FAIL` ou `WARN`.

#### Installation

> `[NOTE]` Le script installe automatiquement Python 3.12 via `winget` si nécessaire.
> Si votre système a Python 3.13+ ou 3.14, le script installe Python 3.12 en parallèle
> et l'utilise pour créer le venv. Vous n'avez pas besoin d'installer Python 3.12 manuellement.
> Si un ancien venv existe avec la mauvaise version de Python, le script le détecte,
> le supprime et le recrée avec Python 3.12.

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -ReportPath .\preflight
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/install-tools.sh --report-path ./preflight
```
</details>

**Checkpoint** : le script installe les outils manquants sous `$HOME/.data2ai`. Les outils Python (Snow CLI, dbt) sont installes dans un environnement virtuel isole **avec Python 3.12**. Le rapport final indique `Toolchain status: READY`.

> Si le rapport affiche `WARN` pour Python (ex. "Found Python 3.14, policy requires 3.12"),
> ce n'est pas bloquant : le script a installé Python 3.12 en parallèle et l'utilise
> pour le venv. Le `WARN` indique seulement que `python` (sans version) pointe encore
> vers 3.14. Pour corriger, rouvrez le terminal ou réinstallez Python 3.12 avec
> l'option "Add python.exe to PATH".

#### Corriger les échecs

Si un outil est en `FAIL`, le rapport affiche la procedure manuelle officielle. Suivez-la, puis relancez :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/install-tools.sh --check
```
</details>

#### Rouvrir le terminal

Si une commande reste introuvable apres l'installation, fermez et rouvrez le terminal pour rafraichir le `PATH`.

<details>
<summary>🐧 <b>Linux/macOS — si le PATH ne persiste pas</b></summary>

```bash
export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"
```

Ajoutez cette ligne a votre `~/.bashrc` ou `~/.zshrc` pour la persistence.
</details>

#### Vérifier les versions

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform version
snow --version
az version
python --version
dbt --version
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform version
snow --version
az version
python3 --version
dbt --version
```
</details>

**Checkpoint** : chaque commande retourne une version. Les versions doivent correspondre a la [politique de versions](../../docs/version-policy.md).

#### Comprendre ce que le script a fait

Repondez a ces questions pour valider votre comprehension :

1. **Ou sont installes Terraform et tflint ?**
   - Windows : `$HOME\.data2ai\bin`
   - Linux/macOS : `$HOME/.data2ai/bin`

2. **Ou sont installes Snow CLI et dbt ?**
   - Dans un environnement virtuel Python isole sous `$HOME/.data2ai/venv`.

3. **Comment le PATH a-t-il ete modifie ?**
   - Windows : le dossier `$HOME\.data2ai\bin` a ete ajoute au PATH utilisateur.
   - Linux/macOS : le script affiche l'instruction `export PATH=...` a ajouter a votre profil shell.

4. **Pourquoi un environnement virtuel isole avec Python 3.12 ?**
   - Pour eviter les conflits avec d'autres projets Python sur votre poste et garantir des versions reproductibles.
   - Python 3.12 est la version requise par la politique de versions. Les packages comme `cffi` et `pyyaml` n'ont pas de wheels pre-compilés pour Python 3.14 sur Windows — utiliser 3.12 evite les echecs de compilation.

---

### 📝 Étape 5.2 — Configurer votre fichier `.env` (10 min)

> `[IMPORTANT]` **Cette étape DOIT être terminée AVANT les étapes 5.3 et 5.4.**
> Les scripts `New-SnowflakeConnection.ps1` et `Learner-Login.ps1` lisent `.env`.
> Sans `.env`, ils affichent un avertissement et ne fonctionnent pas correctement.

Le formateur a pré-rempli `.env.example` avec les paramètres d'accès Snowflake, Azure et Azure DevOps. Vous copiez ce fichier en `.env` et vous ajoutez uniquement vos valeurs personnelles.

**Suivez ces étapes dans l'ordre :**

**1.** Copiez `.env.example` en `.env` :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
Copy-Item .env.example .env
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
cp .env.example .env
```
</details>

**2.** Ouvrez `.env` dans VS Code :

```powershell
code .env
```

**3.** Mettez à jour **uniquement** votre préfixe apprenant dans le fichier :

| Variable | Valeur |
|---|---|
| `LEARNER_PREFIX` | Votre préfixe apprenant (ex. `APP01`, fourni par le formateur) |
| `ENVIRONMENT` | `DEV` (par défaut, ne pas changer) |

> Les autres valeurs (organisation, compte, utilisateur, Azure, Key Vault) sont dans
> `config/shared.env` (commitée, chargée automatiquement par les scripts).
> **Ne modifiez pas** les valeurs partagées dans `.env` — seul `LEARNER_PREFIX` est personnel.

**4.** Sauvegardez le fichier (`Ctrl+S`) et fermez l'éditeur.

**5.** Vérifiez que `.env` existe et contient votre préfixe :

```powershell
# Windows
Test-Path .env
Get-Content .env | Select-String 'LEARNER_PREFIX'
```
```bash
# Linux/macOS
test -f .env && echo "OK"
grep LEARNER_PREFIX .env
```

**Résultat attendu :** `True` / `OK` et `LEARNER_PREFIX=APP01` (ou votre préfixe).

**6.** Vérifiez que `.env` est ignoré par Git :

```bash
git check-ignore .env
```

**Résultat attendu :** `.env` — Git confirme qu'il ignore le fichier.

> `.env` est gitignored. Il ne sera jamais committé.

---

### 📝 Étape 5.3 — Configurer la connexion Snowflake (20 min)

> `[IMPORTANT]` **Prérequis :** l'étape 5.2 (configuration `.env`) doit être terminée.
> Le script `New-SnowflakeConnection.ps1` lit `.env` — s'il est absent, il affiche
> un avertissement et la connexion échouera.

**Avant de continuer, vérifiez que `.env` existe :**

```powershell
# Windows
Test-Path .env
```
```bash
# Linux/macOS
test -f .env && echo "OK"
```

**Si le résultat n'est pas `True` / `OK`, revenez à l'étape 5.2.**

> `[IMPORTANT]` Cette étape configure Snow CLI et crée un fichier PAT local.
> Le PAT est également stocké dans **Azure Key Vault** par le formateur
> (secret partagé `SnowflakePAT`) pour que `Learner-Login.ps1` puisse le récupérer.
> Le fichier `secrets/snowflake_pat.txt` sert de **fallback** si Key Vault est inaccessible.

Le script de connexion lit `.env` automatiquement. Si `SNOWFLAKE_PAT` est vide dans `.env`, il vous le demande de façon masquée.

**Suivez ces étapes dans l'ordre :**

**1.** Lancez le script de connexion :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
.\scripts\New-SnowflakeConnection.ps1
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
chmod +x scripts/new-snowflake-connection.sh
./scripts/new-snowflake-connection.sh
```
</details>

**2.** Si le script demande un PAT, saisissez-le (il ne s'affiche pas à l'écran) :

```text
Snowflake PAT (token): ********
```

Le PAT vous a été fourni par le formateur.

**3.** Vérifiez que la connexion fonctionne :

```bash
snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c training
```

**Résultat attendu :** une ligne avec votre utilisateur, votre rôle et votre compte.

**Si vous voyez `[WARN] No .env file found`**, revenez à l'étape 5.2.

#### Accéder à l'interface web Snowflake (optionnel)

Le formateur vous a fourni un **identifiant Snowflake individuel** (username + password)
pour acceder a l'interface web.

1. Ouvrez **https://app.snowflake.com**
2. Connectez-vous avec :
   - **Username :** `apprenant01` (votre identifiant apprenant)
   - **Password :** fourni par le formateur (14+ caracteres)

> Le PAT (utilise par CLI et Terraform) ne fonctionne pas pour l'interface web.
> L'interface web necessite un username + password.
> Le formateur vous distribue votre password individuel de facon securisee.

---

### 📝 Étape 5.4 — Authentifier Azure et définir les variables Terraform (10 min)

> `[IMPORTANT]` **Prérequis :** l'étape 5.2 (`.env`) doit être terminée.
> Le script `Learner-Login.ps1` lit `.env` pour récupérer votre préfixe apprenant.

> `[IMPORTANT]` **Vous devez relancer cette étape au début de chaque session**
> (nouveau terminal, redémarrage VM). Les variables d'environnement ne persistent
> pas entre les sessions.

Cette étape vous connecte à Azure et définit les variables `ARM_*` et `TF_VAR_snowflake_token`
nécessaires pour Terraform. Il existe **deux modes** — choisissez selon votre situation :

#### Quel mode utiliser ?

| Situation | Mode | Commande |
|---|---|---|
| Vous avez un compte AAD apprenant (fourni par le formateur) | **KV-first** (recommandé) | Étape A ci-dessous |
| Le compte AAD n'est pas configuré, ou vous n'avez pas de navigateur | **Fallback** | Étape B ci-dessous |

---

#### Étape A — Mode KV-first (recommandé, aucun fichier secret requis)

**1.** Lancez le script **sans** `-ForceFallback` :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/learner-login.sh --learner-prefix APP01
```
</details>

> Remplacez `APP01` par **votre** préfixe apprenant fourni par le formateur.

**2.** Une fenêtre de navigateur s'ouvre automatiquement.

> `[IMPORTANT]` **C'est normal !** Le navigateur s'ouvre pour vous authentifier
> avec votre compte AAD (work/school account). C'est le mode KV-first.
> Si aucun navigateur ne s'ouvre, copiez l'URL affichée dans le terminal
> et collez-la dans votre navigateur manuellement.

Connectez-vous avec votre compte apprenant (ex: `apprenant01@mokhtarsellamigmail.onmicrosoft.com`).

**3.** Le script récupère automatiquement les secrets depuis Key Vault et se reconnecte
avec le service principal. Vous n'avez rien d'autre à faire.

**Résultat attendu :**

```text
[PASS] AAD login successful
[INFO] Fetching SP credentials from Key Vault...
[PASS] SP credentials retrieved from Key Vault
[PASS] Snowflake PAT retrieved from Key Vault
[PASS] Logged in to Azure
       Subscription: Azure subscription 1 (...)
       Learner prefix: APP01
[PASS] Environment variables set:
       ARM_CLIENT_ID
       ARM_CLIENT_SECRET (hidden)
       ARM_TENANT_ID
       ARM_SUBSCRIPTION_ID
       LEARNER_PREFIX = APP01
============================================================
 Ready for labs
============================================================
```

**Si le navigateur ne s'ouvre pas ou si la connexion AAD échoue**, passez à l'Étape B.

---

#### Étape B — Mode fallback (si KV-first échoue)

> `[IMPORTANT]` Le mode fallback nécessite les fichiers `secrets/shared-sp.txt` et
> `secrets/snowflake_pat.txt`. Ces fichiers sont distribués par le formateur en secours.
> **S'ils ne sont pas présents, le fallback échouera.** Demandez-les au formateur.

**1.** Vérifiez que les fichiers secrets existent :

```powershell
# Windows
Test-Path secrets\shared-sp.txt
Test-Path secrets\snowflake_pat.txt
```
```bash
# Linux/macOS
test -f secrets/shared-sp.txt && echo "shared-sp OK"
test -f secrets/snowflake_pat.txt && echo "snowflake_pat OK"
```

**Si le résultat n'est pas `True` / `OK`**, demandez ces fichiers au formateur.
Ne continuez pas sans eux.

**2.** Lancez le script avec `-ForceFallback` :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01 -ForceFallback
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/learner-login.sh --learner-prefix APP01 --force-fallback
```
</details>

> Remplacez `APP01` par **votre** préfixe apprenant fourni par le formateur.

**Résultat attendu :**

```text
[INFO] Fallback mode: using local secrets files...
[PASS] Logged in to Azure
       Subscription: Azure subscription 1 (...)
       Learner prefix: APP01
[PASS] Environment variables set
============================================================
 Ready for labs
============================================================
```

---

#### Vérifier la connexion Azure

**Après l'Étape A ou B**, vérifiez que vous êtes connecté :

```bash
az account show --query 'name' -o tsv
```

**Résultat attendu :** le nom de la souscription Azure (ex: `Azure subscription 1`).

#### Vérifier le préfixe apprenant

```powershell
# Windows
$env:LEARNER_PREFIX
```
```bash
# Linux/macOS
echo $LEARNER_PREFIX
```

**Résultat attendu :** votre préfixe (ex: `APP01`).

> `[SECURITY]` Les fichiers `secrets/` sont gitignored. Ne les commitez jamais.
> Préférez le mode KV-first (Étape A) qui ne stocke aucun secret sur votre VM.

---

### 📝 Étape 5.5 — Inspecter la structure du projet type (10 min)

#### Lister les dossiers

```bash
ls -la
ls environments/
ls modules/
ls docs/
ls scripts/
```

**Checkpoint** :

```text
environments/
  dev/
  uat/
  prod/
modules/
docs/
  architecture.md
  naming-conventions.md
  runbook.md
  adr/
scripts/
  Install-Tools.ps1
  install-tools.sh
  New-SnowflakeConnection.ps1
  new-snowflake-connection.sh
  validate.ps1
  validate.sh
azure-pipelines.yml
CODEOWNERS
.gitignore
.gitattributes
.editorconfig
.tflint.hcl
```

#### Vérifier l'absence de code de ressource

```bash
find . -name '*.tf' -type f
```

**Checkpoint** : aucun resultat. Le squelette ne contient aucun fichier `.tf`. Vous les creerez a partir du Jour 1.

#### Comprendre le rôle du squelette

| Element | Role |
|---|---|
| `labs/m01-iac-workflow/` ... `m14-data-products/` | Chaque lab a son propre dossier isole |
| `labs/_templates/` | Modeles de fichiers (provider.tf, versions.tf, variables.tf) |
| `environments/` | Reserve pour M8 (deploiement multi-environnement) |
| `modules/` | Modules reutilisables (cree dans M5, M12, M14) |
| `docs/` | Architecture, conventions de nommage, runbook, decisions |
| `azure-pipelines.yml` | Pipeline CI/CD Azure DevOps |
| `.gitignore` | Exclut state, plans, secrets, tfvars |
| `.tflint.hcl` | Configuration du linter |
| `CODEOWNERS` | Propriete du code et revue obligatoire |
| `scripts/` | Installation, connexion, validation et `Reset-Lab.ps1` |

#### Renommer l'origine (optionnel)

Pour eviter d'ecraser le template, renommez l'origine et ajoutez votre propre depot apprenant :

```bash
git remote rename origin template
git remote add origin <VOTRE_REPO_APPRENANT>
```

> Si vous n'avez pas encore de depot apprenant, ignorez cette etape pour l'instant. Vous le creerez au Jour 1.

---

### 📝 Étape 5.6 — Validation finale (10 min)

> `[IMPORTANT]` **Exécutez chaque commande une par une.**
> Ne copiez pas plusieurs commandes sur la même ligne.
> Chaque commande ci-dessous est séparée — exécutez-les individuellement.

**1.** Relancez le diagnostic des outils :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/install-tools.sh --check
```
</details>

**Résultat attendu :** `Toolchain status: READY`.

**2.** Vérifiez la connexion Snowflake :

```bash
snow sql -q 'SELECT 1' -c training
```

**Résultat attendu :** un résultat contenant `1`.

**3.** Vérifiez le projet Git :

```bash
git status
```

**Résultat attendu :** branche propre, aucun fichier modifié (sauf `preflight.md` et `preflight.json` qui sont ignorés).

**4.** Lancez le test de connectivité complet :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
.\scripts\Test-LabConnectivity.ps1 -SkipDevOps
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/test-lab-connectivity.sh --skip-devops
```
</details>

**Résultat attendu :** `Status: READY` avec 0 FAIL.

> Si `Blob write access` est en FAIL, c'est un problème RBAC côté formateur.
> Le role `Storage Blob Data Contributor` n'a pas été attribué au SP ou
> la propagation n'est pas encore effective (jusqu'à 10 minutes).
> Consultez le [guide de troubleshooting](troubleshooting.md) entrée 15.

---

### 🌐 Étape 5.7 — Vérification Graphique via les Consoles Web

L'apprentissage professionnel associe les commandes du terminal à la maîtrise des interfaces graphiques d'administration.

#### ❄️ Console Snowflake Snowsight (`https://app.snowflake.com`)

1. Ouvrez votre navigateur et accédez à : `https://app.snowflake.com`
2. Saisissez votre identifiant de compte Snowflake : `<ORGANIZATION>-<ACCOUNT>` (valeur présente dans votre `.env`).
3. Connectez-vous avec vos identifiants apprenant :
   - **Nom d'utilisateur :** `<PREFIXE_APPRENANT>` (ex: `APP01`)
   - **Mot de passe :** Renseigné lors de l'initialisation ou via PAT.
4. Vérifiez en haut à droite que votre rôle actif est **`SYSADMIN`** (et non `ACCOUNTADMIN`).
5. Cliquez sur **Worksheets > + SQL Worksheet**, collez et exécutez (`Ctrl + Enter`) :
   ```sql
   SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT(), CURRENT_REGION();
   ```
6. Vous devez voir votre identifiant apprenant et le rôle `SYSADMIN`.

#### 🔵 Portail Microsoft Azure (`https://portal.azure.com`)

1. Accédez au portail officiel : `https://portal.azure.com`
2. Vérifiez votre accès à la souscription de formation indiquée par :
   ```powershell
   az account show --query "name" -o tsv
   ```
3. Naviguez vers le groupe de ressources de la formation et repérez :
   - Le compte de stockage Azure Blob Storage qui hébergera votre state Terraform distant (étudié au Jour 1).
   - Le coffre **Azure Key Vault** contenant le secret PAT Snowflake partagé (`SnowflakePAT`).

---

## 🐛 6. Incident Contrôlé (*Chaos Engineering Lab*)

*Pour apprendre à dépanner sans stress, simulez une anomalie courante de configuration :*

### Symptôme & Injection de l'Anomalie
1. Ouvrez votre `.env` et modifiez temporairement `LEARNER_PREFIX` avec un nom non conforme contenant un tiret et des minuscules :
   ```text
   LEARNER_PREFIX=app-01-test
   ```

### Diagnostic & Observation
Lancez la vérification d'environnement :

```powershell
.\scripts\SelfPacedLab.ps1 -Module 0 -All
```

```bash
./scripts/self-paced-lab.sh --module 0 --all
```

Le validateur signale un échec immédiat sur la conformité de l'identifiant (la regex de validation impose `^[A-Z0-9]{2,10}$`).

### Remédiation
Restaurez votre préfixe officiel (ex: `APP01`), ré-exécutez le script et vérifiez le retour au statut `PASS`.

---

## 🤖 7. Validation Automatisée (*Check My Progress*)

Validez votre avancement avec le moteur d'auto-évaluation du cours :

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
.\scripts\SelfPacedLab.ps1 -Module 0 -All -Report
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
./scripts/self-paced-lab.sh --module 0 --all --report
```
</details>

<details>
<summary>✅ <b>Exemple de Rapport de Validation</b></summary>

```text
[PASS] T1 Git installed and configured
[PASS] T2 Terraform installed and pinned correctly
[PASS] T3 Snow CLI connection 'training' operational
[PASS] T4 Azure CLI authenticated with service principal
[PASS] T5 Project structure validated (no .tf files)
Result: 5/5 Tasks Passed.
Report written to: student-track/_reports/module-00-APP01.md
```
</details>

✅ **Checkpoint Final :** Les conditions suivantes doivent être réunies :

1. `Toolchain status: READY`
2. `az account show --query 'name' -o tsv` affiche la souscription Azure
3. `snow sql -q 'SELECT 1' -c training` retourne un résultat
4. Connexion confirmée dans **Snowflake Snowsight Web UI** avec le rôle `SYSADMIN`
5. `Test-LabConnectivity.ps1` affiche `Status: READY` (0 FAIL)
6. Le projet type est cloné et ne contient aucun fichier `.tf`

```text
Ready for Day 1
```

---

## 🏆 8. Défi Autonome (*Unguided Challenge*)

> **Scénario :** Votre équipe vous demande de préparer un second environnement de test avec un préfixe différent.
> **Contraintes :**
> - Créez un fichier `.env.test` avec un préfixe `APP01TEST` (conforme à la regex);
> - Vérifiez que `git check-ignore .env.test` confirme l'ignorance du fichier;
> - Lancez `Learner-Login.ps1 -LearnerPrefix APP01TEST` et vérifiez que les variables d'environnement sont correctement définies;
> - Ne modifiez jamais le fichier `.env` principal.

| Critère d'Évaluation | Points |
|---|---:|
| Fichier `.env.test` créé avec préfixe conforme | 30 pts |
| `git check-ignore` confirme l'ignorance | 20 pts |
| `Learner-Login` réussit avec le nouveau préfixe | 30 pts |
| Aucune modification du `.env` principal | 20 pts |
| **Total** | **100 pts** |

---

## 🧹 9. Conservation & Point de Reprise (*FinOps Teardown*)

> **M00 est un module de conservation obligatoire.** Ne détruisez rien — l'environnement est la base de tous les labs M01 à M14.

### Point de reprise pour les sessions suivantes

À partir du Jour 1, **tous les fichiers `.tf` que vous créerez** iront dans le dossier du lab correspondant :

- `labs/m01-iac-workflow/main.tf`, `locals.tf`, `outputs.tf`... pour M1;
- `labs/m05-modules/modules/landing-zone/` pour M5;
- `labs/m08-environments/dev/`, `uat/`, `prod/` pour M8;
- etc.

Chaque lab est **isolé** : il a son propre dossier, son propre state et ses propres ressources (préfixées par le numéro de module, ex. `APP01_M01_RAW_DEV`). Utilisez `Reset-Lab.ps1` pour nettoyer avant/après un lab :

```powershell
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M01
```

Les scripts `validate.ps1` et `validate.sh` dans `scripts/` vérifient votre travail localement avant de pousser.

> ⚠️ **WARNING** : Vous devez relancer `Learner-Login` au début de chaque session (nouveau terminal, redémarrage VM). Les variables d'environnement ne persistent pas entre les sessions.

Passez à [M1 — Premier déploiement Terraform Snowflake](../../day-01/module-01-iac-workflow/lab.md).

---

## Navigation

[<- Jour 0](../README.md) · **Lab M00** · [Lab M1 ->](../../day-01/module-01-iac-workflow/lab.md)
