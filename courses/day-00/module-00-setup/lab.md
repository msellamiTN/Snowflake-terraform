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

## Ordre d'execution des scripts

> `[IMPORTANT]` L'ordre des scripts est important. Suivez cette sequence exacte.

| # | Script | Quand | Action |
|---|---|---|---|
| 0 | `Set-ExecutionPolicy` | Une seule fois | Autorise les scripts PowerShell (Windows) |
| 1 | `Install-Tools.ps1` | Une seule fois | Installe Terraform, Snow CLI, dbt, tflint |
| 2 | `New-SnowflakeConnection.ps1` | Une seule fois | Configure Snow CLI + ecrit le PAT dans `secrets/snowflake_pat.txt` (fallback) |
| 3 | `Learner-Login.ps1` | **Chaque session** | Login Azure + recupere le PAT depuis Key Vault + set `TF_VAR_snowflake_token` |
| 4 | `Test-LabConnectivity.ps1` | Verification | Valide tous les acces (Snowflake + Azure + Git + Terraform) |

```powershell
# 0. Autoriser les scripts (une seule fois, Windows seulement)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 1. Installer les outils (une seule fois)
.\scripts\Install-Tools.ps1

# 2. Configurer Snowflake (une seule fois)
.\scripts\New-SnowflakeConnection.ps1

# 3. Login Azure + variables Terraform (CHaque session)
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01

# 4. Verifier tout
.\scripts\Test-LabConnectivity.ps1 -SkipDevOps
```

> `[IMPORTANT]` `Learner-Login.ps1` recupere le PAT depuis **Azure Key Vault**
> (secret `SnowflakePAT-APP01` pour l'apprenant APP01). Si Key Vault est inaccessible,
> il utilise `secrets/snowflake_pat.txt` comme fallback (cree par `New-SnowflakeConnection.ps1`).
> Sans cela, `terraform plan` vous demandera `var.snowflake_token` manuellement.

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

> `[WINDOWS]` Si vous obtenez l'erreur `l'execution de scripts est desactivee`,
> autorisez les scripts locaux une seule fois :
>
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```
>
> `RemoteSigned` est le parametre standard pour un poste de formation.
> Il autorise les scripts locaux mais bloque les scripts telecharges non signes.

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
| `ENVIRONMENT` | `DEV` (par defaut) |

La configuration partagee (organisation, compte, utilisateur, Azure, Key Vault) est dans
`config/shared.env` (committee, chargee automatiquement par `Learner-Login.ps1`).

Le PAT n'est **pas** dans `.env` — il est recupere depuis Azure Key Vault par `Learner-Login.ps1`.

> Les identifiants Azure (service principal partage) sont dans `secrets/shared-sp.txt`.
> Vous n'avez pas besoin de les copier dans `.env` — le script `Learner-Login` les lit automatiquement.

> `.env` est gitignored. Il ne sera jamais commite.

### 3.3 — Verifier que `.env` est ignore

```bash
git check-ignore .env
```

**Checkpoint** : `.env` — Git confirme qu'il ignore le fichier.

---

## Etape 4 — Configurer la connexion Snowflake (20 min)

> `[IMPORTANT]` Cette etape configure Snow CLI et cree un fichier PAT local.
> Le PAT est ensuite stocke dans **Azure Key Vault** par le formateur
> (secret `SnowflakePAT-APP01`) pour que `Learner-Login.ps1` puisse le recuperer.
> Le fichier `secrets/snowflake_pat.txt` sert de **fallback** si Key Vault est inaccessible.

Le script de connexion lit `.env` automatiquement. Si `SNOWFLAKE_PAT` est vide dans `.env`, il vous le demande de facon masquee.

### 4.1 — Lancer le script

<details>
<summary>Windows (PowerShell)</summary>

```powershell
.\scripts\New-SnowflakeConnection.ps1
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

### 4.2 — Verifier la connexion

```bash
snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c training
```

**Checkpoint** : une ligne avec votre utilisateur, votre role et votre compte.

### 4.3 — Acceder a l'interface web Snowflake (optionnel)

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

## Etape 5 — Authentifier Azure avec le service principal partage (10 min)

> `[IMPORTANT]` Cette etape doit etre executee **apres** l'etape 4 (Snowflake).
> Le script `Learner-Login.ps1` recupere le PAT depuis **Azure Key Vault**
> (secret `SnowflakePAT-APP01`) et definit `TF_VAR_snowflake_token` pour Terraform.
> Si Key Vault est inaccessible, il utilise `secrets/snowflake_pat.txt` comme fallback.
> Sans cela, `terraform plan` vous demandera `var.snowflake_token` manuellement.

Le formateur vous a fourni un fichier `secrets/shared-sp.txt` contenant les identifiants
d'un **service principal partage**. Ce SP contourne l'authentification MFA d'Azure.

> `secrets/shared-sp.txt` est gitignored. Ne le commitez jamais.

### 5.1 — Lancer le script de login

<details>
<summary>Windows (PowerShell)</summary>

```powershell
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01
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
- lit `config/shared.env` (config partagee, committee);
- lit `.env` (valeurs personnelles : `LEARNER_PREFIX`);
- lit `secrets/shared-sp.txt` (meme fichier pour tous les apprenants);
- se connecte a Azure avec le service principal (pas de MFA);
- definit les variables `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`;
- recupere le PAT depuis **Azure Key Vault** (`SnowflakePAT-APP01`) et definit `TF_VAR_snowflake_token`;
- fallback : si Key Vault est inaccessible, lit `secrets/snowflake_pat.txt`;
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
       TF_VAR_snowflake_token (from PAT file)

============================================================
 Ready for labs
============================================================
```

### 5.2 — Verifier la connexion Azure

```bash
az account show --query 'name' -o tsv
```

**Checkpoint** : le nom de la souscription Azure.

### 5.3 — Verifier le prefixe apprenant

```bash
echo $LEARNER_PREFIX       # Linux/macOS
echo $env:LEARNER_PREFIX   # Windows PowerShell
```

**Checkpoint** : votre prefixe (ex. `APP01`).

> **IMPORTANT** Vous devez relancer `Learner-Login` au debut de chaque session
> (nouveau terminal, redemarrage VM). Les variables d'environnement ne persistent
> pas entre les sessions.

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

## Etape 6 — Première Connexion aux Consoles Web (Snowsight & Azure Portal)

L'apprentissage professionnel associe les commandes du terminal à la maîtrise des interfaces graphiques d'administration.

### 6.1 — Connexion à Snowflake Snowsight Web UI

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

### 6.2 — Vérification du Portail Microsoft Azure

1. Accédez au portail officiel : `https://portal.azure.com`
2. Vérifiez votre accès à la souscription de formation indiquée par :
   ```powershell
   az account show --query "name" -o tsv
   ```
3. Naviguez vers le groupe de ressources de la formation et repérez :
   - Le compte de stockage Azure Blob Storage qui hébergera votre state Terraform distant (étudié au Jour 1).
   - Le coffre **Azure Key Vault** contenant votre secret PAT Snowflake (`SnowflakePAT-APP01`).

---

## 🐛 Chaos Lab M00 — Diagnostic d'une Panne d'Environnement

*Pour apprendre à dépanner sans stress, simulez une anomalie courante de configuration :*

1. **Injection de l'anomalie :** Ouvrez votre `.env` et modifiez temporairement `LEARNER_PREFIX` avec un nom non conforme contenant un tiret et des minuscules :
   ```text
   LEARNER_PREFIX=app-01-test
   ```
2. **Observation du diagnostic :** Lancez la vérification d'environnement :
   ```powershell
   .\scripts\SelfPacedLab.ps1 -Module 0 -All
   ```
3. **Résultat :** Le validateur signale un échec immédiat sur la conformité de l'identifiant (la regex de validation impose `^[A-Z0-9]{2,10}$`).
4. **Remédiation :** Restaurez votre préfixe officiel (ex: `APP01`), ré-exécutez le script et vérifiez le retour au statut `PASS`.

---

## Checkpoint final

Le Jour 0 est termine uniquement lorsque les conditions suivantes sont reunies :

1. `Toolchain status: READY`
2. `az account show --query 'name' -o tsv` affiche la souscription Azure
3. `snow sql -q 'SELECT 1' -c training` retourne un resultat
4. Connexion confirmée dans **Snowflake Snowsight Web UI** avec le rôle `SYSADMIN`
5. `Test-LabConnectivity.ps1` affiche `Status: READY` (0 FAIL)
6. Le projet type est clone et ne contient aucun fichier `.tf`

```text
Ready for Day 1
```

---

## La suite : votre racine de travail

A partir du Jour 1, **tous les fichiers `.tf` que vous creerez** iront dans le dossier du lab correspondant :

- `labs/m01-iac-workflow/main.tf`, `locals.tf`, `outputs.tf`... pour M1;
- `labs/m05-modules/modules/landing-zone/` pour M5;
- `labs/m08-environments/dev/`, `uat/`, `prod/` pour M8;
- etc.

Chaque lab est **isole** : il a son propre dossier, son propre state et ses propres ressources (prefixees par le numero de module, ex. `APP01_M01_RAW_DEV`). Utilisez `Reset-Lab.ps1` pour nettoyer avant/apres un lab :

```powershell
.\scripts\Reset-Lab.ps1 -LearnerPrefix APP01 -Lab M01
```

Les scripts `validate.ps1` et `validate.sh` dans `scripts/` verifient votre travail localement avant de pousser.

Passez a [M1 — Premier deploiement Terraform Snowflake](../../day-01/module-01-iac-workflow/lab.md).

---

## Navigation

[<- Jour 0](../README.md) · **Lab M00** · [Lab M1 ->](../../day-01/module-01-iac-workflow/lab.md)
