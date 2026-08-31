# Jour 0 — Résultats attendus

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Rapport de la chaîne d'outils

### Format

Le rapport est généré par `Install-Tools.ps1 -ReportPath` ou `install-tools.sh --report-path`.

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

### Critères de succès

| Critère | Condition |
|---|---|
| Outils Core | Tous en `PASS` |
| Outils Course | Tous en `PASS` ou procédure manuelle affichée |
| Statut final | `Toolchain status: READY` |
| Code de sortie | 0 |
| Secret | Aucune valeur secrète dans le rapport |

## Connexion Snowflake

### Sortie attendue du script de connexion

```text
============================================================
 Snowflake CLI connection setup
============================================================

The PAT is entered securely and never displayed or logged.

Snowflake organization name: MYORG
Snowflake account name: MYACCOUNT
Snowflake user name: DATA2AI
Snowflake PAT (token): ********

Creating the connection...
[OK] Connection 'training' created.

Testing the connection...
[OK] Connection test succeeded.

Done.

Next steps:
  - Use the connection:  snow sql -q 'SELECT 1' -c training
  - Do not store the PAT in any file.
  - Rotate the PAT when the training module is complete.
```

### Vérification de la connexion

```bash
snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c training
```

**Attendu :** une ligne contenant votre utilisateur, votre rôle et votre compte.

## Projet type cloné

### Commandes exécutées depuis le clone

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
    ├── New-SnowflakeConnection.ps1
    ├── new-snowflake-connection.sh
    ├── validate.ps1
    └── validate.sh
```

### Absence de code de ressource

```bash
find $HOME/Data2AI-Labs/data-platform -name '*.tf' -type f
```

**Attendu :** aucun résultat.

## Checklist finale

- [ ] `Toolchain status: READY`
- [ ] Tous les outils Core en `PASS`
- [ ] `snow sql -q 'SELECT 1' -c training` retourne un résultat
- [ ] Projet type cloné sous `$HOME/Data2AI-Labs/data-platform`
- [ ] Scripts présents dans `scripts/` du clone
- [ ] Aucun fichier `.tf` dans le projet type
- [ ] Aucun secret dans le rapport ou l'historique de commandes
- [ ] Vous savez où sont installés les outils et pourquoi
- [ ] Vous savez que tous les fichiers `.tf` futurs iront dans ce clone
