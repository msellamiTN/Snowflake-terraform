# Lab Jour 0 — Préparer votre environnement

> [<- Jour 0](../README.md) · **M00 Setup** · [Jour 1 ->](../../day-01/module-01-iac-workflow/lab.md)

**Duree cible : 1 h 30**

## Resultat attendu

A la fin de ce lab :

- le **projet type** est clone sous `$HOME/Data2AI-Labs/data-platform`;
- Git, Terraform, Snowflake CLI, Azure CLI et dbt sont disponibles dans le terminal;
- la connexion Snowflake `training` repond a `snow sql -q 'SELECT 1' -c training`;
- Azure est authentifie via le service principal partage;
- la validation finale affiche `Toolchain status: READY`.

> **Toutes les commandes s'executent depuis la racine du clone** (`$HOME/Data2AI-Labs/data-platform`).

---

## Etape 1 — Cloner le projet type (5 min)

Le projet type est le depot `data-platform-starter`. Il contient les scripts d'installation, la structure de gouvernance et les validateurs. **C'est votre racine de travail pour toute la formation.**

Le depot du projet type est : `https://github.com/msellamiTN/data-platform-starter.git`

<details>
<summary>Windows (PowerShell)</summary>

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

### 1.1 — Verifier que les scripts sont presents

```bash
ls scripts/
```

**Checkpoint** :

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

> A partir d'ici, **toutes les commandes s'executent depuis la racine du clone**.

---

## Etape 2 — Installer et verifier les outils (20 min)

Le Jour 0 est **automatise**. Vous executez les scripts qui se trouvent dans le clone, puis vous lisez le rapport.

- **Windows** : `scripts/Install-Tools.ps1`
- **Linux/macOS** : `scripts/install-tools.sh`

Les deux scripts ont le meme contrat : memes versions, memes verifications, meme format de rapport.

### 2.1 — Diagnostic initial

Executez le script en mode `Check` pour voir l'etat actuel sans rien installer :

<details>
<summary>Windows (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check -ReportPath .\preflight
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
chmod +x scripts/install-tools.sh
./scripts/install-tools.sh --check --report-path ./preflight
```
</details>

**Checkpoint** : un rapport s'affiche et deux fichiers sont crees (`preflight.md` et `preflight.json`). Les outils deja installes sont en `PASS`, les autres en `FAIL` ou `WARN`.

### 2.2 — Installation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -ReportPath .\preflight
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
./scripts/install-tools.sh --report-path ./preflight
```
</details>

**Checkpoint** : le script installe les outils manquants sous `$HOME/.data2ai`. Les outils Python (Snow CLI, dbt) sont installes dans un environnement virtuel isole. Le rapport final indique `Toolchain status: READY`.

### 2.3 — Corriger les echecs

Si un outil est en `FAIL`, le rapport affiche la procedure manuelle officielle. Suivez-la, puis relancez :

<details>
<summary>Windows (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
./scripts/install-tools.sh --check
```
</details>

### 2.4 — Rouvrir le terminal

Si une commande reste introuvable apres l'installation, fermez et rouvrez le terminal pour rafraichir le `PATH`.

<details>
<summary>Linux/macOS — si le PATH ne persiste pas</summary>

```bash
export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"
```

Ajoutez cette ligne a votre `~/.bashrc` ou `~/.zshrc` pour la persistence.
</details>

### 2.5 — Verifier les versions

<details>
<summary>Windows (PowerShell)</summary>

```powershell
terraform version
snow --version
az version
python --version
dbt --version
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
terraform version
snow --version
az version
python3 --version
dbt --version
```
</details>

**Checkpoint** : chaque commande retourne une version. Les versions doivent correspondre a la [politique de versions](../../docs/version-policy.md).

### 2.6 — Comprendre ce que le script a fait

Repondez a ces questions pour valider votre comprehension :

1. **Ou sont installes Terraform et tflint ?**
   - Windows : `$HOME\.data2ai\bin`
   - Linux/macOS : `$HOME/.data2ai/bin`

2. **Ou sont installes Snow CLI et dbt ?**
   - Dans un environnement virtuel Python isole sous `$HOME/.data2ai/venv`.

3. **Comment le PATH a-t-il ete modifie ?**
   - Windows : le dossier `$HOME\.data2ai\bin` a ete ajoute au PATH utilisateur.
   - Linux/macOS : le script affiche l'instruction `export PATH=...` a ajouter a votre profil shell.

4. **Pourquoi un environnement virtuel isole ?**
   - Pour eviter les conflits avec d'autres projets Python sur votre poste et garantir des versions reproductibles.

---

## Etape 3 — Configurer votre fichier `.env` (10 min)

Le formateur a pre-rempli `.env.example` avec les parametres d'acces Snowflake, Azure et Azure DevOps. Vous copiez ce fichier en `.env` et vous ajoutez uniquement vos valeurs personnelles.

### 3.1 — Copier `.env.example`

<details>
<summary>Windows (PowerShell)</summary>

```powershell
cp .env.example .env
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
cp .env.example .env
```
</details>

### 3.2 — Mettre a jour vos valeurs personnelles

Ouvrez `.env` dans votre editeur. Mettez a jour uniquement :

| Variable | Valeur |
|---|---|
| `LEARNER_PREFIX` | Votre prefixe apprenant (ex. `APP01`, fourni par le formateur) |
| `SNOWFLAKE_PAT` | Votre PAT temporaire (fourni par le formateur) |

Les autres valeurs (organisation, compte, utilisateur, role, Azure, Azure DevOps) sont deja remplies par le formateur.

> Les identifiants Azure (service principal partage) sont dans `secrets/shared-sp.txt`.
> Vous n'avez pas besoin de les copier dans `.env` — le script `Learner-Login` les lit automatiquement.

> `.env` est gitignored. Il ne sera jamais commite.

### 3.3 — Verifier que `.env` est ignore

```bash
git check-ignore .env
```

**Checkpoint** : `.env` — Git confirme qu'il ignore le fichier.

---

## Etape 4 — Authentifier Azure avec le service principal partage (10 min)

Le formateur vous a fourni un fichier `secrets/shared-sp.txt` contenant les identifiants
d'un **service principal partage**. Ce SP contourne l'authentification MFA d'Azure.

> `secrets/shared-sp.txt` est gitignored. Ne le commitez jamais.

### 4.1 — Lancer le script de login

<details>
<summary>Windows (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Learner-Login.ps1 -LearnerPrefix APP01
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
chmod +x scripts/learner-login.sh
./scripts/learner-login.sh APP01
```
</details>

> Remplacez `APP01` par votre prefixe apprenant fourni par le formateur.

Le script :
- lit `secrets/shared-sp.txt` (meme fichier pour tous les apprenants);
- se connecte a Azure avec le service principal (pas de MFA);
- definit les variables `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`;
- definit `LEARNER_PREFIX` pour l'isolation de vos ressources.

**Checkpoint** :

```text
============================================================
 Learner Login: APP01
============================================================

[INFO] Logging in with shared service principal...
[PASS] Logged in to Azure
       Subscription: Azure subscription 1 (...)
       Tenant: ...
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

### 4.2 — Verifier la connexion Azure

```bash
az account show --query 'name' -o tsv
```

**Checkpoint** : le nom de la souscription Azure.

### 4.3 — Verifier le prefixe apprenant

```bash
echo $LEARNER_PREFIX       # Linux/macOS
echo $env:LEARNER_PREFIX   # Windows PowerShell
```

**Checkpoint** : votre prefixe (ex. `APP01`).

> **IMPORTANT** Vous devez relancer `Learner-Login` au debut de chaque session
> (nouveau terminal, redemarrage VM). Les variables d'environnement ne persistent
> pas entre les sessions.

---

## Etape 5 — Configurer la connexion Snowflake (20 min)

Le script de connexion lit `.env` automatiquement. Si `SNOWFLAKE_PAT` est vide dans `.env`, il vous le demande de facon masquee.

### 5.1 — Lancer le script

<details>
<summary>Windows (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\New-SnowflakeConnection.ps1
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
chmod +x scripts/new-snowflake-connection.sh
./scripts/new-snowflake-connection.sh
```
</details>

Le script lit les parametres depuis `.env` et cree la connexion `training`.

**Checkpoint** :

```text
[INFO] Loading .env from .../.env

Creating the connection...
[OK] Connection 'training' created.
[OK] Config file permissions restricted to current user.

Testing the connection...
[OK] Connection test succeeded.

Done.
```

Si `SNOWFLAKE_PAT` etait vide dans `.env`, le script affiche :

```text
Snowflake PAT (token): ********
```

Saisissez votre PAT. Il ne s'affiche pas a l'ecran.

### 5.2 — Verifier la connexion

```bash
snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c training
```

**Checkpoint** : une ligne avec votre utilisateur, votre role et votre compte.

### 5.3 — Acceder a l'interface web Snowflake (optionnel)

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

## Etape 6 — Inspecter la structure du projet type (10 min)

### 6.1 — Lister les dossiers

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

### 6.2 — Verifier l'absence de code de ressource

```bash
find . -name '*.tf' -type f
```

**Checkpoint** : aucun resultat. Le squelette ne contient aucun fichier `.tf`. Vous les creerez a partir du Jour 1.

### 6.3 — Comprendre le role du squelette

| Element | Role |
|---|---|
| `environments/dev/`, `uat/`, `prod/` | Racines Terraform pour chaque environnement |
| `modules/` | Modules reutilisables que vous creerez |
| `docs/` | Architecture, conventions de nommage, runbook, decisions |
| `azure-pipelines.yml` | Pipeline CI/CD Azure DevOps |
| `.gitignore` | Exclut state, plans, secrets, tfvars |
| `.tflint.hcl` | Configuration du linter |
| `CODEOWNERS` | Propriete du code et revue obligatoire |
| `scripts/` | Installation, connexion et validation locale |

### 6.4 — Renommer l'origine (optionnel)

Pour eviter d'ecraser le template, renommez l'origine et ajoutez votre propre depot apprenant :

```bash
git remote rename origin template
git remote add origin <VOTRE_REPO_APPRENANT>
```

> Si vous n'avez pas encore de depot apprenant, ignorez cette etape pour l'instant. Vous le creerez au Jour 1.

---

## Etape 7 — Validation finale (10 min)

### 7.1 — Relancer le diagnostic

<details>
<summary>Windows (PowerShell)</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
./scripts/install-tools.sh --check
```
</details>

**Checkpoint** : `Toolchain status: READY`.

### 7.2 — Verifier la connexion Snowflake

```bash
snow sql -q 'SELECT 1' -c training
```

**Checkpoint** : un resultat contenant `1`.

### 7.3 — Verifier le projet

```bash
git status
```

**Checkpoint** : branche propre, aucun fichier modifie (sauf `preflight.md` et `preflight.json` qui sont ignores).

### 7.4 — Lancer le test de connectivite complet

<details>
<summary>Windows (PowerShell)</summary>

```powershell
.\scripts\Test-LabConnectivity.ps1 -SkipDevOps
```
</details>

<details>
<summary>Linux/macOS (Bash)</summary>

```bash
./scripts/test-lab-connectivity.sh --skip-devops
```
</details>

**Checkpoint** : `Status: READY` avec 0 FAIL.

> Si `Blob write access` est en FAIL, c'est un probleme RBAC cote formateur.
> Le role `Storage Blob Data Contributor` n'a pas ete attribue au SP ou
> la propagation n'est pas encore effective (jusqu'a 10 minutes).
> Consultez le [guide de troubleshooting](troubleshooting.md) entree 15.

---

## Checkpoint final

Le Jour 0 est termine uniquement lorsque les conditions suivantes sont reunies :

1. `Toolchain status: READY`
2. `az account show --query 'name' -o tsv` affiche la souscription Azure
3. `snow sql -q 'SELECT 1' -c training` retourne un resultat
4. `Test-LabConnectivity.ps1` affiche `Status: READY` (0 FAIL)
5. Le projet type est clone et ne contient aucun fichier `.tf`

```text
Ready for Day 1
```

---

## La suite : votre racine de travail

A partir du Jour 1, **tous les fichiers `.tf` que vous creerez** iront dans ce clone :

- `environments/dev/versions.tf`, `provider.tf`, `main.tf`... pour M1;
- `modules/landing-zone/` pour M5;
- `environments/uat/` et `environments/prod/` pour M8;
- etc.

Chaque atelier indique le chemin exact depuis la racine du clone. Les scripts `validate.ps1` et `validate.sh` dans `scripts/` verifient votre travail localement avant de pousser.

Passez a [M1 — Premier deploiement Terraform Snowflake](../../day-01/module-01-iac-workflow/lab.md).
