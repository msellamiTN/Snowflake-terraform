# Étape 2 — Configurer la connexion Snowflake et valider

**Durée cible : 30 minutes**

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Résultat attendu

À la fin de cette étape :

- la connexion Snowflake `training` répond à `snow sql -q 'SELECT 1' -c training`;
- la structure du projet type est inspectée et comprise;
- la validation finale affiche `Toolchain status: READY`.

> **Toutes les commandes s'exécutent depuis la racine du clone** (`$HOME/Data2AI-Labs/data-platform`).

---

## 1. Configurer votre fichier `.env`

Le formateur a pré-rempli `.env.example` avec les paramètres d'accès Snowflake, Azure et Azure DevOps. Vous copiez ce fichier en `.env` et vous ajoutez uniquement vos valeurs personnelles.

### 1.1 — Copier `.env.example`

**Windows :**

```powershell
cp .env.example .env
```

**Linux/macOS :**

```bash
cp .env.example .env
```

### 1.2 — Mettre à jour vos valeurs personnelles

Ouvrez `.env` dans votre éditeur. Mettez à jour uniquement :

| Variable | Valeur |
|---|---|
| `LEARNER_PREFIX` | Votre préfixe apprenant (3-5 lettres majuscules, fourni par le formateur) |
| `SNOWFLAKE_PAT` | Votre PAT temporaire (fourni par le formateur) |

Les autres valeurs (organisation, compte, utilisateur, rôle, Azure, Azure DevOps) sont déjà remplies par le formateur.

> `.env` est gitignored. Il ne sera jamais commité.

### 1.3 — Vérifier que `.env` est ignoré

```bash
git check-ignore .env
```

**Attendu :** `.env` — Git confirme qu'il ignore le fichier.

---

## 2. Configurer la connexion Snowflake

Le script de connexion lit `.env` automatiquement. Si `SNOWFLAKE_PAT` est vide dans `.env`, il vous le demande de façon masquée.

### 2.1 — Lancer le script

**Windows :**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\New-SnowflakeConnection.ps1
```

**Linux/macOS :**

```bash
chmod +x scripts/new-snowflake-connection.sh
./scripts/new-snowflake-connection.sh
```

Le script lit les paramètres depuis `.env` et crée la connexion `training`.

**Attendu :**

```text
[INFO] Loading .env from .../.env
[OK] Connection 'training' created.
[OK] Connection test succeeded.
```

Si `SNOWFLAKE_PAT` était vide dans `.env`, le script affiche :

```text
Snowflake PAT (token): ********
```

Saisissez votre PAT. Il ne s'affiche pas à l'écran.

### 2.2 — Vérifier la connexion

```bash
snow sql -q 'SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()' -c training
```

**Attendu :** une ligne avec votre utilisateur, votre rôle et votre compte.

---

## 2. Inspecter la structure du projet type

### 2.1 — Lister les dossiers

```bash
ls -la
ls environments/
ls modules/
ls docs/
ls scripts/
```

**Attendu :**

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

### 2.2 — Vérifier l'absence de code de ressource

```bash
find . -name '*.tf' -type f
```

**Attendu :** aucun résultat. Le squelette ne contient aucun fichier `.tf`. Vous les créerez à partir du Jour 1.

### 2.3 — Comprendre le rôle du squelette

| Élément | Rôle |
|---|---|
| `environments/dev/`, `uat/`, `prod/` | Racines Terraform pour chaque environnement |
| `modules/` | Modules réutilisables que vous créerez |
| `docs/` | Architecture, conventions de nommage, runbook, décisions |
| `azure-pipelines.yml` | Pipeline CI/CD Azure DevOps |
| `.gitignore` | Exclut state, plans, secrets, tfvars |
| `.tflint.hcl` | Configuration du linter |
| `CODEOWNERS` | Propriété du code et revue obligatoire |
| `scripts/` | Installation, connexion et validation locale |

### 2.4 — Renommer l'origine (optionnel)

Pour éviter d'écraser le template, renommez l'origine et ajoutez votre propre dépôt apprenant :

```bash
git remote rename origin template
git remote add origin <VOTRE_REPO_APPRENANT>
```

> Si vous n'avez pas encore de dépôt apprenant, ignorez cette étape pour l'instant. Vous le créerez au Jour 1.

---

## 3. Validation finale

### 3.1 — Relancer le diagnostic

**Windows :**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check
```

**Linux/macOS :**

```bash
./scripts/install-tools.sh --check
```

**Attendu :** `Toolchain status: READY`.

### 3.2 — Vérifier la connexion

```bash
snow sql -q 'SELECT 1' -c training
```

**Attendu :** un résultat contenant `1`.

### 3.3 — Vérifier le projet

```bash
git status
```

**Attendu :** branche propre, aucun fichier modifié (sauf `preflight.md` et `preflight.json` qui sont ignorés).

---

## Checkpoint

[CHECK] Les trois conditions suivantes sont réunies :

1. `Toolchain status: READY`
2. `snow sql -q 'SELECT 1' -c training` retourne un résultat
3. Le projet type est cloné et ne contient aucun fichier `.tf`

Si ce checkpoint passe, le Jour 0 est terminé. Passez à [M1 — Premier déploiement](../../day-01/module-01-iac-workflow/lab.md).

---

## La suite : votre racine de travail

À partir du Jour 1, **tous les fichiers `.tf` que vous créerez** iront dans ce clone :

- `environments/dev/versions.tf`, `provider.tf`, `main.tf`... pour M1;
- `modules/landing-zone/` pour M5;
- `environments/uat/` et `environments/prod/` pour M8;
- etc.

Chaque atelier indique le chemin exact depuis la racine du clone. Les scripts `validate.ps1` et `validate.sh` dans `scripts/` vérifient votre travail localement avant de pousser.
