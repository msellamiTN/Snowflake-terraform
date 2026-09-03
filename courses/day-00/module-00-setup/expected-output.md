# Jour 0 — Resultats attendus

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Rapport de la chaine d'outils

### Format

Le rapport est genere par `Install-Tools.ps1 -ReportPath` ou `install-tools.sh --report-path`.

**Fichier Markdown (`preflight.md`) :**

```markdown
# Toolchain report

Mode: CHECK (no installation)
Generated: 2026-XX-XX XX:XX:XX

| Tool | Tier | Status | Detail |
|---|---|---|---|
| Git | Core | PASS | git version 2.XX.X |
| Terraform | Core | PASS | Terraform v1.14.5 |
| Python | Core | PASS | Python 3.12.X |
| Snowflake CLI | Core | PASS | Snowflake CLI version: X.XX.X |
| dbt | Course | PASS | dbt-core X.X.X |
| Azure CLI | Course | PASS | Available |
| tflint | Optional | PASS | tflint X.XX.X |
| VS Code | Optional | PASS | X.XX.X |
| OpenSSL | Optional | PASS | OpenSSL X.X.X |

Core failures: 0
Course failures: 0
Warnings: 0
```

**Fichier JSON (`preflight.json`) :**

```json
[
  { "Name": "Git", "Tier": "Core", "Status": "PASS", "Detail": "git version 2.XX.X" },
  ...
]
```

### Criteres de succes

| Critere | Condition |
|---|---|
| Outils Core | Tous en `PASS` |
| Outils Course | Tous en `PASS` ou procedure manuelle affichee |
| Statut final | `Toolchain status: READY` |
| Code de sortie | 0 |
| Secret | Aucune valeur secrete dans le rapport |

## Authentification Azure (service principal partage)

### Sortie attendue du script Learner-Login

Avec `secrets/shared-sp.txt` fourni par le formateur :

```text
============================================================
 Learner Login: APP01
============================================================

[INFO] Logging in with shared service principal...
[PASS] Logged in to Azure
       Subscription: Azure subscription 1 (8c42d5b2-...)
       Tenant: 55fca982-...
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

### Verification

```bash
az account show --query 'name' -o tsv
```

**Attendu :** `Azure subscription 1`

> `[IMPORTANT]` Relancez `Learner-Login` au debut de chaque nouvelle session.

## Acces Snowflake web (optionnel)

L'apprenant peut se connecter a l'interface web Snowflake avec son username + password
individuel (fourni par le formateur).

- URL : https://app.snowflake.com
- Username : `apprenant01` a `apprenant10`
- Password : 14+ caracteres (respecte la politique Snowflake)

> Le PAT (CLI/Terraform) et le password (web) sont deux methodes distinctes.

## Connexion Snowflake

### Sortie attendue du script de connexion

Avec `.env` pre-rempli par le formateur et `SNOWFLAKE_PAT` renseigne :

```text
============================================================
 Snowflake CLI connection setup
============================================================

[INFO] Loading .env from .../.env

Creating the connection...
[OK] Connection 'training' written to .../.snowflake/config.toml
[OK] Config file permissions restricted to current user.

Testing the connection...
[OK] Connection test succeeded.

Done.

Next steps:
  - Use the connection:  snow sql -q 'SELECT 1' -c training
  - The token is read from the file automatically - no env var needed.
  - Do not store the PAT in any committed file.
  - Rotate the PAT when the training module is complete.
```

Si `SNOWFLAKE_PAT` etait vide dans `.env`, le script demande le PAT de facon masquee avant de continuer.

### Verification de la connexion

```bash
snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c training
```

**Attendu :** une ligne contenant votre utilisateur, votre role et votre compte.

```text
+-----------------------------------------------------+
| CURRENT_USER() | CURRENT_ROLE() | CURRENT_ACCOUNT() |
|----------------+----------------+-------------------|
| DATA2AI        | SYSADMIN       | HQ33884           |
+-----------------------------------------------------+
```

## Projet type clone

### Commandes executees depuis le clone

```bash
cd $HOME/Data2AI-Labs/data-platform
```

### Structure attendue

```text
$HOME/Data2AI-Labs/data-platform/
├── README.md
├── .gitignore
├── .gitattributes
├── .editorconfig
├── .tflint.hcl
├── azure-pipelines.yml
├── CODEOWNERS
├── docs/
│   ├── architecture.md
│   ├── naming-conventions.md
│   ├── runbook.md
│   └── adr/
│       └── 0001-record-architecture-decisions.md
├── environments/
│   ├── dev/
│   │   ├── README.md
│   │   ├── backend.hcl.example
│   │   └── terraform.tfvars.example
│   ├── uat/
│   │   ├── README.md
│   │   ├── backend.hcl.example
│   │   └── terraform.tfvars.example
│   └── prod/
│       ├── README.md
│       ├── backend.hcl.example
│       └── terraform.tfvars.example
├── modules/
│   └── README.md
└── scripts/
    ├── Install-Tools.ps1
    ├── install-tools.sh
    ├── Learner-Login.ps1
    ├── learner-login.sh
    ├── New-SnowflakeConnection.ps1
    ├── new-snowflake-connection.sh
    ├── Test-LabConnectivity.ps1
    ├── test-lab-connectivity.sh
    ├── validate.ps1
    └── validate.sh
```

### Absence de code de ressource

```bash
find $HOME/Data2AI-Labs/data-platform -name '*.tf' -type f
```

**Attendu :** aucun resultat.

## Rapport de connectivite

```text
============================================================
 Lab Connectivity Test
============================================================

== 1. CLI Tools
  [PASS] Git
  [PASS] Terraform
  [PASS] Snowflake CLI
  [PASS] Azure CLI
  [PASS] Python
  [PASS] dbt
  [PASS] tflint

== 2. Snowflake Connectivity
  [PASS] Snow CLI connection 'training'
  [PASS] PAT file
  [PASS] Snowflake query

== 3. Azure Connectivity
  [PASS] Azure CLI authentication
  [PASS] Azure tenant
  [PASS] Subscription match
  [PASS] Service principal
  [PASS] Resource group
  [PASS] Azure Storage Account
  [PASS] Azure Blob Container
  [PASS] Blob write access
  [WARN] Azure Key Vault          (Day 4 — may not exist yet)

== 5. Git and Repository
  [PASS] Git remote
  [PASS] Git branch
  [PASS] .env is gitignored
  [PASS] secrets/ is gitignored

== 6. Terraform Environment
  [PASS] Terraform files in environments/dev
  [PASS] Terraform init
  [PASS] Provider lock file

============================================================
 Summary
============================================================

  PASS : 25
  FAIL : 0
  WARN : 1
  SKIP : 1

Status: READY
```

> `Azure Key Vault` est en `WARN` car il n'est utilise qu'a partir du Jour 4.
> `Azure DevOps` est en `SKIP` car `-SkipDevOps` est passe.

## Checklist finale

- [ ] `Toolchain status: READY`
- [ ] Tous les outils Core en `PASS`
- [ ] `.env` copie depuis `.env.example` et complete avec `LEARNER_PREFIX` et `SNOWFLAKE_PAT`
- [ ] `git check-ignore .env` retourne `.env`
- [ ] `secrets/shared-sp.txt` present et gitignored
- [ ] `Learner-Login` execute avec votre prefixe (`APP01`, `APP02`...)
- [ ] `az account show --query 'name' -o tsv` affiche la souscription
- [ ] `snow sql -q 'SELECT 1' -c training` retourne un resultat
- [ ] `Test-LabConnectivity.ps1 -SkipDevOps` affiche `Status: READY` (0 FAIL)
- [ ] Projet type clone sous `$HOME/Data2AI-Labs/data-platform`
- [ ] Scripts presents dans `scripts/` du clone
- [ ] Aucun fichier `.tf` dans le projet type
- [ ] Aucun secret dans le rapport ou l'historique de commandes
- [ ] Vous savez ou sont installes les outils et pourquoi
- [ ] Vous savez que tous les fichiers `.tf` futurs iront dans ce clone
