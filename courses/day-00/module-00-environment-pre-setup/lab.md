> ⚠️ **Module déprécié** — ce contenu est conservé à titre de référence. Utilisez le nouveau lab fusionné : [M0 — Day 0](../module-00-day0-setup/lab.md).

# Lab M0 — Préparation de l'environnement (Zero-Error)

**Durée :** 120 min  
**Code :** `project/` (global)  
**Patterns :** Installation outils, génération de clés RSA, création d'un utilisateur Snowflake dédié, authentification JWT key-pair, fallback password, gestion des secrets, `.gitignore`

---

## Contexte métier

Une équipe plateforme ne peut industrialiser ses déploiements si chaque poste utilise des versions, des identités et des secrets différents. M0 réduit le risque d'accès non autorisé et rend l'environnement de travail reproductible.

## Contexte architecture

```mermaid
flowchart LR
    PREREQ[Prérequis entreprise] --> M0[M0 — Poste sécurisé]
    M0 --> M1[M1 — Workflow Terraform]
```

| Référentiel | Alignement |
|---|---|
| Pattern | Environment Bootstrap |
| Azure Well-Architected | Sécurité, Excellence opérationnelle |
| Azure CAF | Ready |
| Platform Engineering | Poste d'ingénierie reproductible |

## Pattern d'entreprise

Le pattern **Environment Bootstrap** établit une chaîne d'outils vérifiable, une identité technique dédiée et une frontière claire entre configuration versionnée et secrets locaux.

## Objectifs

À l'issue de ce lab, vous aurez un poste de travail **100 % opérationnel** pour suivre l'ensemble de la formation sans erreur :

- ✅ Terraform, Snowflake CLI (`snow`), Git, OpenSSL et VS Code installés et dans le `PATH`.
- ✅ Une connexion admin `DATA2AI` fonctionnelle dans `snow` via JWT key-pair ou PAT (contourne MFA).
- ✅ Un utilisateur service `TERRAFORM_SVC` créé avec une clé publique RSA ou un PAT, prêt pour l'authentification.
- ✅ Un fichier `terraform.tfvars` local créé pour chaque environnement de lab.
- ✅ La confirmation que `terraform init`, `terraform validate` et `terraform plan` fonctionnent dans `project/01-day1-basics`.
- ✅ `.gitignore` correctement configuré : aucun secret ne pourra être commité.

---

## 📋 Préambule : authentification Snowflake

Cette formation propose **deux méthodes** d'authentification programmatique à Snowflake, toutes deux compatibles avec MFA :

| Méthode | Outils requis | Complexité | Recommandée pour |
|---|---|---|---|
| **A — JWT key-pair** (RSA) | OpenSSL | Moyenne | Production, CI/CD |
| **B — PAT** (Programmatic Access Token) | Aucun (Snowsight) | **Faible** | Formation, démarrage rapide |

- **Méthode A — JWT key-pair** : générer une paire de clés RSA avec OpenSSL, assigner la clé publique à l'utilisateur dans Snowsight, configurer `snow` avec `authenticator = SNOWFLAKE_JWT`.
- **Méthode B — PAT** : créer un token directement dans Snowsight (ou via SQL), sauvegarder le token dans un fichier, configurer `snow` avec `authenticator = PROGRAMMATIC_ACCESS_TOKEN`. **Pas besoin d'OpenSSL ni de clés RSA.**

> 🔒 **Règle d'or** : aucune authentification par mot de passe dans ce lab. Que vous utilisiez JWT ou PAT, la credential reste locale dans `secrets/` et ne transite jamais par Git.

> **Prérequis :** Les outils (Terraform, Snowflake CLI, Git, OpenSSL, VS Code) doivent être installés et vérifiés. Voir [Atelier 0 — Installation des outils](../module-00-tools-setup/lab.md).

> 💡 **Choisissez votre méthode** : Si vous voulez aller vite, choisissez **PAT (Méthode B)** — pas de génération de clés, pas d'OpenSSL. Si vous voulez apprendre la méthode production, choisissez **JWT key-pair (Méthode A)**.

## 📁 Étape 1 — Lire `access.txt` (source de vérité)

Le fichier `access.txt` à la racine du repo contient les identifiants Snowflake. **Ne le modifiez pas et ne le commitez pas.**

Les quatre valeurs dont vous aurez besoin :

| Valeur | Exemple (fichier `access.txt`) | Utilisation |
|---|---|---|
| Admin login | `DATA2AI` | Utilisateur admin (JWT ou PAT) |
| Organization name | `<snowflake-organization>` | Paramètre `organization_name` |
| Account name | `<snowflake-account>` | Paramètre `account_name` |
| Account identifier | `<snowflake-organization>-<snowflake-account>` | Host Snowflake complet |

---

## 🔁 Vue d'ensemble du workflow M0

```mermaid
flowchart TD
    A[Lire access.txt] --> B[Atelier 0 : outils installés]
    B --> C[Vérifier PATH et outils]
    C --> D[Ouvrir le repo dans VS Code]
    D --> E[Créer le dossier secrets/]
    E --> CHOIX{Méthode ?}
    CHOIX -->|JWT key-pair| F[Générer paire de clés RSA]
    F --> G[Assigner clé publique à DATA2AI dans Snowsight]
    G --> H[Configurer snow admin en JWT]
    H --> I[Créer TERRAFORM_SVC avec clé publique]
    I --> K[Configurer provider.tf en JWT]
    CHOIX -->|PAT| F2[Créer PAT dans Snowsight]
    F2 --> H2[Configurer snow admin en PAT]
    H2 --> I2[Créer TERRAFORM_SVC + PAT]
    I2 --> K
    K --> M[Créer terraform.tfvars]
    M --> N[terraform init / validate / plan]
    N --> O{Succès ?}
    O -->|Oui| P[Lab M0 terminé]
    O -->|Non| Q[Troubleshooting M0]
    Q --> M
```

### Séquence d'authentification JWT

Le diagramme de séquence ci-dessous montre l'interaction entre le participant, Terraform, la CLI Snowflake et le compte Snowflake lors de l'authentification JWT :

```mermaid
sequenceDiagram
    participant Dev as Participant
    participant OpenSSL as OpenSSL
    participant Snow as Snow CLI
    participant SF as Snowflake
    participant TF as Terraform

    Dev->>OpenSSL: genrsa 2048 + pkcs8 -nocrypt
    OpenSSL-->>Dev: snowflake_key.p8 (privée)
    OpenSSL-->>Dev: snowflake_key.pub (publique)

    Dev->>Snow: snow connection add -c admin (JWT key-pair)
    Snow->>SF: Génère JWT signé avec snowflake_key.p8
    SF->>SF: Vérifie RSA_PUBLIC_KEY sur DATA2AI
    SF-->>Snow: Session admin JWT OK

    Dev->>Snow: snow sql -c admin -q CREATE USER TERRAFORM_SVC + RSA_PUBLIC_KEY
    Snow->>SF: Crée l'utilisateur avec la clé publique
    SF-->>Snow: Utilisateur créé

    Dev->>Snow: snow connection add -c terraform_svc (JWT)
    Snow->>SF: Génère JWT signé avec snowflake_key.p8
    SF->>SF: Vérifie RSA_PUBLIC_KEY
    SF-->>Snow: Session JWT OK

    Dev->>TF: terraform plan (provider lit private_key_path)
    TF->>SF: Génère JWT + appels API
    SF-->>TF: Ressources lues/créées
    TF-->>Dev: Plan affiché sans erreur
```

---

## 🛠️ Étape 2 — Vérifier les outils (5 min)

**Objectif :** Vérifier que les outils installés dans l'Atelier 0 sont fonctionnels.

> Les outils doivent déjà être installés via [Atelier 0 — Installation des outils](../module-00-tools-setup/lab.md). Cette étape est une vérification rapide.

### 2.1 Vérification rapide

Téléchargez Git : <https://git-scm.com/download/win>

Vérifiez qu'OpenSSL est accessible :

```powershell
& "C:\Program Files\Git\mingw64\bin\openssl.exe" version
# Attendu : OpenSSL 3.x.x
```

### 2.4 Visual Studio Code

Extensions recommandées :
- **HashiCorp Terraform**
- **Mermaid Markdown Syntax Highlighting**

Ouvrez le repo :

```powershell
code .
```

---

## 📁 Étape 3 — Ouvrir le projet et créer `secrets/`

**Objectif :** Créer le dossier `secrets/` qui accueillera les clés RSA et autres fichiers sensibles.

**Action 1 — Positionnez-vous dans la racine du repo** :

```powershell
cd $HOME\training\snowflake-terraform
```

**Action 2 — Créez le dossier qui accueillera les secrets** :

```powershell
New-Item -ItemType Directory -Path secrets -Force | Out-Null
```

**Action 3 — Vérifiez la structure attendue** :

```text
courses/
docs/
project/
scripts/
secrets/          <-- créé ici
tools/
```

> 🔒 Ce dossier est déjà ignoré par `.gitignore`. Ne le renommez pas.

### ✅ Checkpoint — Après l'Étape 3

- [ ] Le dossier `secrets/` existe à la racine du repo
- [ ] `git status` n'affiche pas `secrets/` (gitigné)

---

## 🔐 Étape 4 — Authentification Snowflake

### Choix de la méthode

Vous avez deux options pour cette étape :

- **Méthode A — JWT key-pair (RSA)** : Étapes 4A → 5A → 6A ci-dessous.
- **Méthode B — PAT (Programmatic Access Token)** : Étapes 4B → 5B → 6B ci-dessous.

> 💡 **PAT est plus simple** : pas besoin d'OpenSSL, pas de gestion de clés RSA. Créez un token dans Snowsight et c'est tout.

---

### Méthode B — PAT (Programmatic Access Token)

> ⚡ **Plus simple que JWT key-pair** : pas d'OpenSSL, pas de clés RSA. Créez un token dans Snowsight et configurez `snow`.

#### Étape 4B — Créer un PAT pour `DATA2AI`

**Action 1 — Créez le PAT depuis Snowsight** :

1. Connectez-vous à **https://app.snowflake.com** en tant que `DATA2AI` (avec MFA dans le navigateur)
2. Allez dans **Admin → Users → DATA2AI → Programmatic Access Tokens**
3. Cliquez **Add → Create Token**
4. Nommez le token `admin_pat`
5. Définissez l'expiration (ex: 90 jours)
6. **Copiez le token secret** affiché (il ne sera plus visible ensuite)

> ⚠️ **Le token secret ne s'affiche qu'une seule fois.** Copiez-le immédiatement.

**Action 2 — Sauvegardez le token dans un fichier** :

```powershell
# Depuis la racine du repo
$patToken = "<collez-le-token-secret-ici>"
$patToken | Set-Content -Path secrets\snowflake_admin_pat.txt -NoNewline
```

> 🔒 Ce fichier est dans `secrets/` (gitigné). Ne le commitez jamais.

**Action 3 — Gérez le network policy** :

Si vous voyez le message **"Missing network policy"** dans Snowsight :

```sql
-- Exécutez dans Snowsight (compte ACCOUNTADMIN)
-- Option 1 : Créer une network policy minimale
CREATE NETWORK POLICY IF NOT EXISTS lab_policy
  ALLOWED_IP_LIST = ('0.0.0.0/0');

ALTER ACCOUNT SET NETWORK_POLICY = lab_policy;

-- Option 2 : Bypass temporaire (1440 min = 24h)
-- ALTER USER DATA2AI ADD PROGRAMMATIC ACCESS TOKEN admin_pat
--   MINS_TO_BYPASS_NETWORK_POLICY_REQUIREMENT = 1440;
```

> 📌 **En formation**, l'option 1 (network policy `0.0.0.0/0`) est la plus simple. En production, restreignez les IP.

#### Étape 5B — Configurer la connexion admin en PAT

**Action 1 — Supprimez l'ancienne connexion admin si elle existe** :

```powershell
snow connection remove admin
```

**Action 2 — Ajoutez la connexion admin avec PAT** :

```powershell
snow connection add -n <SNOWFLAKE_ADMIN_CONNECTION> `
  -a "<snowflake-account>" `
  -h "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com" `
  -u "<SNOWFLAKE_ADMIN_USER>" `
  -r "<SNOWFLAKE_ROLE>" `
  -A "PROGRAMMATIC_ACCESS_TOKEN" `
  -t "$PWD\secrets\snowflake_admin_pat.txt" `
  --no-interactive
```

> L'option `-A "PROGRAMMATIC_ACCESS_TOKEN"` active l'authentification par PAT.
> L'option `-t` spécifie le chemin du fichier contenant le token.

**Action 3 — Testez la connexion admin** :

```powershell
snow connection test -c <SNOWFLAKE_ADMIN_CONNECTION>
# Attendu : Connection status: OK
```

#### Étape 6B — Créer `TERRAFORM_SVC` avec PAT

**Action 1 — Créez l'utilisateur service** :

```powershell
snow sql -c admin -q "
CREATE USER IF NOT EXISTS <SNOWFLAKE_TERRAFORM_USER>
  TYPE = SERVICE
  DEFAULT_ROLE = <SNOWFLAKE_ROLE>;
GRANT ROLE <SNOWFLAKE_ROLE> TO USER <SNOWFLAKE_TERRAFORM_USER>;
"
```

**Action 2 — Créez un PAT pour `TERRAFORM_SVC`** :

```sql
-- Dans Snowsight ou via snow sql -c admin
ALTER USER <SNOWFLAKE_TERRAFORM_USER> ADD PROGRAMMATIC ACCESS TOKEN terraform_pat
  DAYS_TO_EXPIRY = 90;
```

> Copiez le token secret retourné.

**Action 3 — Sauvegardez le token** :

```powershell
$patToken = "<collez-le-token-terraform-svc-ici>"
$patToken | Set-Content -Path secrets\snowflake_terraform_pat.txt -NoNewline
```

**Action 4 — Ajoutez la connexion `terraform_svc` en PAT** :

```powershell
snow connection add -n <SNOWFLAKE_TERRAFORM_CONNECTION> `
  -a "<snowflake-account>" `
  -h "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com" `
  -u "<SNOWFLAKE_TERRAFORM_USER>" `
  -r "<SNOWFLAKE_ROLE>" `
  -A "PROGRAMMATIC_ACCESS_TOKEN" `
  -t "$PWD\secrets\snowflake_terraform_pat.txt" `
  --no-interactive
```

**Action 5 — Testez la connexion** :

```powershell
snow connection test -c <SNOWFLAKE_TERRAFORM_CONNECTION>
# Attendu : Connection status: OK

snow sql -c <SNOWFLAKE_TERRAFORM_CONNECTION> -q "SELECT current_user()"
# Attendu : TERRAFORM_SVC
```

#### ✅ Checkpoint PAT

- [ ] `snow connection test -c admin` retourne `OK`
- [ ] `snow connection test -c terraform_svc` retourne `OK`
- [ ] `secrets/snowflake_admin_pat.txt` existe
- [ ] `secrets/snowflake_terraform_pat.txt` existe
- [ ] `config.toml` contient 2 sections avec `authenticator = "PROGRAMMATIC_ACCESS_TOKEN"`

> ✅ **PAT terminé** → passez directement à l'**Étape 7** (Configurer Terraform). Ignorez les étapes 4A/5A/6A ci-dessous.

---

### Méthode A — JWT key-pair (RSA)

#### Étape 4A — Générer la paire de clés RSA

**Objectif :** Créer une paire de clés RSA 2048-bit au format PKCS#8 (sans passphrase) pour l'authentification JWT.

> ⚠️ **Exécutez ces commandes depuis la racine du repo**, pas depuis l'intérieur de `secrets/`.
> Vérifiez avec `Get-Location` — vous devez être dans `snowflake-terraform/`.

**Action 1 — Générez la clé privée et la clé publique** :

```powershell
# Définir le chemin d'OpenSSL (fourni avec Git for Windows)
$openssl = "C:\Program Files\Git\mingw64\bin\openssl.exe"

# Vérifier qu'OpenSSL fonctionne
& $openssl version
# Attendu : OpenSSL 3.x.x

# Générer la clé privée (PKCS#8, sans passphrase)
& $openssl genrsa 2048 | & $openssl pkcs8 -topk8 -inform PEM -out secrets\snowflake_key.p8 -nocrypt

# Extraire la clé publique
& $openssl rsa -in secrets\snowflake_key.p8 -pubout -out secrets\snowflake_key.pub
```

**Action 2 — Vérifiez le format de la clé privée** :

```powershell
Get-Content secrets\snowflake_key.p8 | Select-Object -First 2
```

Attendu **exactement** :

```text
-----BEGIN PRIVATE KEY-----
MII...
```

> ⚠️ Si vous voyez `-----BEGIN ENCRYPTED PRIVATE KEY-----`, supprimez le fichier et régénérez avec `-nocrypt`.

**Action 3 — Vérifiez que la clé privée et la clé publique correspondent** :

```powershell
$pubFromPriv = (& $openssl rsa -in secrets\snowflake_key.p8 -pubout 2>$null | Where-Object { $_ -notmatch 'BEGIN|END' }) -join ''
$pubFile = (Get-Content secrets\snowflake_key.pub | Where-Object { $_ -notmatch 'BEGIN|END' }) -join ''
if ($pubFromPriv -eq $pubFile) { "Clés OK" } else { "ERREUR : clés non correspondantes" }
```

> 🛠️ **Erreur fréquente :** `Can't open "secrets\snowflake_key.p8" for writing, No such file or directory`
> ➜ Vous êtes **à l'intérieur** du dossier `secrets/`. Remontez à la racine du repo :
> ```powershell
> cd ..\..  # ou cd $HOME\training\snowflake-terraform
> ```
> Les commandes utilisent le chemin relatif `secrets\snowflake_key.p8` — elles doivent être exécutées depuis la racine.

**Action 4 — Créez le fichier `snowflake_key.oneline`** (clé publique sans marqueurs, requis par `project/admin-fix/`) :

```powershell
(Get-Content secrets\snowflake_key.pub | Where-Object { $_ -notmatch 'BEGIN|END' }) -join '' | Set-Content secrets\snowflake_key.oneline
```

> **Note :** Le fichier `snowflake_key.oneline` est utilisé par `project/admin-fix/main.tf` pour enregistrer la clé publique sur l'utilisateur `TERRAFORM_SVC` via Terraform. Il contient la clé publique sur une seule ligne, sans les marqueurs `-----BEGIN/END PUBLIC KEY-----`.

### ✅ Checkpoint — Après l'Étape 4

Vérifiez que votre dossier `secrets/` contient :

```text
secrets/
  ├── snowflake_key.p8        ← clé privée PKCS#8
  ├── snowflake_key.pub       ← clé publique PEM
  └── snowflake_key.oneline   ← clé publique sur une ligne (pour admin-fix)
```

- [ ] `snowflake_key.p8` commence par `-----BEGIN PRIVATE KEY-----`
- [ ] `snowflake_key.pub` commence par `-----BEGIN PUBLIC KEY-----`
- [ ] `snowflake_key.oneline` contient la clé sur une seule ligne sans marqueurs

---

## 👤 Étape 5A — Créer l'utilisateur `TERRAFORM_SVC` (JWT)

**Objectif :** Créer un utilisateur service dédié dans Snowflake avec la clé publique RSA, pour l'authentification JWT.

### 5A.1 Comprendre `config.toml` — le fichier de configuration de Snowflake CLI

Snowflake CLI utilise un fichier de configuration global appelé **`config.toml`** pour stocker les connexions et les paramètres de logs.

**Emplacement du fichier** :

```text
# Snowflake CLI 3.25+ (Windows) :
C:\Users\<votre-utilisateur>\AppData\Local\snowflake\config.toml

# Versions antérieures / Linux / macOS :
~/.snowflake/config.toml
```

> 📌 **Pour trouver le chemin exact sur votre machine**, exécutez `snow connection add` une fois — le message de confirmation indique où le fichier a été écrit.

> 📌 **Pour les débutants — Qu'est-ce que `config.toml` ?**
>
> `config.toml` est un fichier au format **TOML** (Tom's Obvious Minimal Language) qui centralise toutes les connexions Snowflake CLI. Au lieu de retaper vos identifiants à chaque commande `snow`, le fichier les mémorise de façon sécurisée.
>
> **Analogie :** C'est comme le carnet d'adresses de votre téléphone. Au lieu de taper un numéro à chaque appel, vous sélectionnez un contact. `config.toml` est le carnet d'adresses de `snow`.
>
> **Création automatique :** Le fichier est créé automatiquement par la commande `snow connection add`. Vous n'avez **pas** à le créer manuellement.

**Structure du fichier `config.toml`** :

```toml
# Section [connections] — définit les connexions nommées
[connections]
[connections.<nom-connexion>]
account = "<account>"
host = "<host>.snowflakecomputing.com"
user = "<utilisateur>"
role = "<role>"
# ... paramètres d'authentification ...

# Section [logs] — configure les logs (optionnel)
[logs]
level = "INFO"
path = "<chemin-vers-logs>"
```

> ⚠️ **Sécurité :** `config.toml` contient des secrets (mot de passe, chemin de clé privée). Ce fichier **ne doit jamais être commité dans Git**. Il est stocké dans le profil utilisateur (`AppData\Local\snowflake\`), pas dans le repo.

> 📌 **Le fichier `config.toml` n'existe pas encore** : il sera créé automatiquement par la commande `snow connection add` à l'étape 5A.2 ci-dessous. Le chemin exact sera affiché dans le message de confirmation. Passez directement à la suite.

### 5A.2 Assigner la clé publique à l'utilisateur admin

> ⚠️ **Étape obligatoire** : Snowflake enforce MFA pour les connexions par mot de passe (bundle `2024_08`). La solution est d'utiliser **JWT key-pair** pour l'admin aussi — pas de mot de passe, pas de MFA.

**Action 1 — Assignez la clé publique RSA à `DATA2AI` depuis Snowsight** :

1. Connectez-vous à **https://app.snowflake.com** en tant que `DATA2AI` (avec MFA dans le navigateur)
2. Ouvrez un **SQL Worksheet** et exécutez :

```sql
-- Récupérez d'abord la clé oneline dans PowerShell :
-- $pubKey = (Get-Content secrets\snowflake_key.pub | Where-Object { $_ -notmatch 'BEGIN|END' }) -join ''
-- Write-Output $pubKey
-- Copiez le résultat et collez-le ci-dessous

ALTER USER <SNOWFLAKE_ADMIN_USER> SET RSA_PUBLIC_KEY = '<collez-la-clé-oneline-ici>';

-- Vérifiez
DESCRIBE USER <SNOWFLAKE_ADMIN_USER>;
-- HAS_KEYPAIR doit être true
```

### 5A.3 Configurer la connexion admin en JWT

**Action 1 — Supprimez l'ancienne connexion admin si elle existe** :

```powershell
# Si une connexion admin existe déjà (mot de passe), supprimez-la
snow connection remove admin
```

**Action 2 — Ajoutez la connexion admin avec JWT** :

```powershell
snow connection add -n <SNOWFLAKE_ADMIN_CONNECTION> `
  -a "<snowflake-account>" `
  -h "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com" `
  -u "<SNOWFLAKE_ADMIN_USER>" `
  -r "<SNOWFLAKE_ROLE>" `
  -A "SNOWFLAKE_JWT" `
  -k "$PWD\secrets\snowflake_key.p8" `
  --no-interactive
```

> L'option `-A "SNOWFLAKE_JWT"` active l'authentification par clé RSA (JWT), qui contourne MFA.
> L'option `-k` spécifie le chemin de la clé privée PKCS#8.
> L'option `--no-interactive` evite les invites pour les champs optionnels.

> 📌 **Ce que fait `snow connection add` :** La commande écrit une nouvelle section `[connections.<nom>]` dans `config.toml`. Après cette commande, vérifiez :
>
> ```powershell
> Get-Content "$env:LOCALAPPDATA\snowflake\config.toml"
> # Attendu : une section [connections.admin] avec account, host, user, role, authenticator, private_key_file
> ```

**Action 3 — Testez la connexion admin** :

```powershell
snow connection test -c <SNOWFLAKE_ADMIN_CONNECTION>
```

Attendu :

```text
Connection status: OK
```

> 📌 **Le flag `-c` lit `config.toml` :** Chaque commande `snow -c <nom>` recherche la section `[connections.<nom>]` dans `config.toml`. Vous n'avez jamais à retaper vos identifiants.

> 🛠️ **Erreur `MFA authentication is required` ?** Voir la section Troubleshooting — cela signifie que la clé publique n'a pas été assignée à l'utilisateur dans Snowsight (étape 5A.2).

### 5A.4 Créer l'utilisateur service

**Action 1 — Récupérez la clé publique sans en-têtes** :

```powershell
$pubKey = (Get-Content secrets\snowflake_key.pub | Where-Object { $_ -notmatch 'BEGIN|END' }) -join ''
```

**Action 2 — Créez `TERRAFORM_SVC` dans Snowflake** :

```powershell
snow sql -c admin -q "
CREATE USER IF NOT EXISTS <SNOWFLAKE_TERRAFORM_USER>
  TYPE = SERVICE
  DEFAULT_ROLE = <SNOWFLAKE_ROLE>
  RSA_PUBLIC_KEY = '$pubKey';
GRANT ROLE <SNOWFLAKE_ROLE> TO USER <SNOWFLAKE_TERRAFORM_USER>;
"
```

**Action 3 — Vérifiez que l'utilisateur a bien la clé RSA** :

```powershell
snow sql -c admin -q "DESCRIBE USER <SNOWFLAKE_TERRAFORM_USER>" 2>&1 | Select-String "HAS_KEYPAIR|RSA_PUBLIC_KEY"
```

Attendu : `HAS_KEYPAIR: true`.

### ✅ Checkpoint — Après l'Étape 5A

- [ ] `snow connection test -c admin` retourne `OK`
- [ ] L'utilisateur `<SNOWFLAKE_TERRAFORM_USER>` existe dans Snowflake
- [ ] `HAS_KEYPAIR: true` confirmé pour `<SNOWFLAKE_TERRAFORM_USER>`
- [ ] `config.toml` contient la section `[connections.admin]` avec `authenticator = "SNOWFLAKE_JWT"`

---

## 🔌 Étape 6A — Tester la connexion JWT

**Objectif :** Valider que l'authentification JWT fonctionne avec la clé privée générée à l'Étape 4.

**Action 1 — Ajoutez la connexion JWT dans Snowflake CLI** :

```powershell
snow connection add -n <SNOWFLAKE_TERRAFORM_CONNECTION> `
  -a "<snowflake-account>" `
  -h "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com" `
  -u "<SNOWFLAKE_TERRAFORM_USER>" `
  -r "<SNOWFLAKE_ROLE>" `
  -A "SNOWFLAKE_JWT" `
  -k "$PWD\secrets\snowflake_key.p8" `
  --no-interactive
```

> 📌 **Cette commande ajoute une seconde section dans `config.toml` :**
>
> ```powershell
> Get-Content "$env:LOCALAPPDATA\snowflake\config.toml"
> # Attendu : deux sections [connections.admin] et [connections.terraform_svc]
> ```
>
> Le fichier `config.toml` final doit ressembler à :
>
> ```toml
> [connections]
> [connections.admin]
> account = "<snowflake-account>"
> host = "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com"
> user = "<SNOWFLAKE_ADMIN_USER>"
> role = "<SNOWFLAKE_ROLE>"
> authenticator = "SNOWFLAKE_JWT"
> private_key_file = "...\\secrets\\snowflake_key.p8"
>
> [connections.terraform_svc]
> account = "<snowflake-account>"
> host = "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com"
> user = "<SNOWFLAKE_TERRAFORM_USER>"
> role = "<SNOWFLAKE_ROLE>"
> authenticator = "SNOWFLAKE_JWT"
> private_key_file = "...\\secrets\\snowflake_key.p8"
> ```
>
> **Vous n'éditez jamais `config.toml` manuellement** — `snow connection add` s'en charge.

**Action 2 — Testez la connexion JWT** :

```powershell
snow connection test -c <SNOWFLAKE_TERRAFORM_CONNECTION>
snow sql -c <SNOWFLAKE_TERRAFORM_CONNECTION> -q "SELECT current_user()"
```

Attendu : `TERRAFORM_SVC`.

### ✅ Checkpoint — Après l'Étape 6A

- [ ] `snow connection test -c terraform_svc` retourne `OK`
- [ ] `SELECT current_user()` retourne `<SNOWFLAKE_TERRAFORM_USER>`
- [ ] `config.toml` contient les deux sections : `[connections.admin]` et `[connections.terraform_svc]`
- [ ] Les deux sections contiennent `authenticator = "SNOWFLAKE_JWT"` et `private_key_file`

> ✅ **JWT key-pair terminé** → passez directement à l'**Étape 7** (Configurer Terraform).

---

## ⚙️ Étape 7 — Configurer Terraform

**Objectif :** Configurer le `provider.tf` et le `terraform.tfvars` pour que Terraform puisse se connecter à Snowflake.

### 7.1 Profondeur du `private_key_path`

Le chemin de la clé privée dépend du dossier d'exécution Terraform. Voici la table de référence pour tous les labs :

| Dossier d'exécution | `private_key_path` relatif |
|---|---|
| `project/01-day1-basics` | `../../secrets/snowflake_key.p8` |
| `project/02-day1-state` | `../../secrets/snowflake_key.p8` |
| `project/03-day2-modules/environments/dev` | `../../../../secrets/snowflake_key.p8` |
| `project/04-day3-rbac/environments/dev` | `../../../../secrets/snowflake_key.p8` |
| `project/05-capstone/environments/dev` | `../../../../secrets/snowflake_key.p8` |

### 7.2 Le pattern `deployment_mode` (commun à tous les labs)

Tous les fichiers `provider.tf` du projet utilisent un **pattern unifié** avec la variable `deployment_mode` qui bascule entre JWT et password automatiquement. **Vous n'avez pas besoin de modifier le `provider.tf`** — il est déjà configuré.

**Ouvrez le fichier `provider.tf` existant** dans `project/01-day1-basics/` :

```powershell
code project/01-day1-basics/provider.tf
```

Le contenu doit être :

```hcl
provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  role              = var.snowflake_role

  # Training mode: password fallback
  password      = var.deployment_mode == "training" ? var.snowflake_password : null
  authenticator = var.deployment_mode == "training" ? "snowflake" : null

  # Production mode: JWT key-pair auth
  private_key_path = var.deployment_mode == "production" ? var.private_key_path : null
}
```

> **Pattern :** La variable `deployment_mode` contrôle l'authentification :
> - `"production"` → utilise `private_key_path` + JWT automatique (utilisé dans ce lab)
> - `"training"` → utilise `snowflake_password` + `authenticator = "snowflake"` (legacy, non utilisé)
>
> Ce pattern est utilisé dans **tous** les modules du projet (`01-day1-basics` à `05-capstone`). Vous n'avez jamais à modifier `provider.tf` — seul le `terraform.tfvars` change.

```mermaid
flowchart LR
    subgraph "deployment_mode = production (ce lab)"
        PR[terraform.tfvars
private_key_path = .../key.p8] --> P2[provider.tf
JWT automatique]
    end
    P2 --> SF[Snowflake]
```

### 7.3 `terraform.tfvars` en mode production (JWT)

Si la connexion JWT a réussi à l'Étape 6, configurez le `terraform.tfvars` en mode production.

**Action 1 — Copiez le fichier d'exemple** :

```powershell
cd $HOME\training\snowflake-terraform\project\01-day1-basics
copy terraform.tfvars.example terraform.tfvars
```

**Action 2 — Écrivez `terraform.tfvars` à partir de `.env` (mode production)** :

```text
if ($env:DEPLOYMENT_MODE -eq 'production') {
    $tfvars = @"
deployment_mode        = "<DEPLOYMENT_MODE>"
snowflake_organization = "<snowflake-organization>"
snowflake_account      = "<snowflake-account>"
snowflake_user         = "<SNOWFLAKE_TERRAFORM_USER>"
snowflake_role         = "<SNOWFLAKE_ROLE>"
private_key_path       = "<PRIVATE_KEY_PATH>"
environment            = "DEV"
warehouse_size         = "X-SMALL"
"@
    $tfvars | Set-Content -Path terraform.tfvars
}
```

### ✅ Checkpoint — Après l'Étape 7

Vérifiez que votre dossier `project/01-day1-basics/` contient :

```text
project/01-day1-basics/
  ├── main.tf              ← ressources Snowflake (déjà existant)
  ├── provider.tf          ← provider avec deployment_mode (déjà existant, ne pas modifier)
  ├── variables.tf         ← variables avec validation (déjà existant)
  ├── outputs.tf           ← outputs (déjà existant)
  ├── terraform.tfvars     ← VOTRE fichier, créé à cette étape
  └── terraform.tfvars.example ← template (ne pas modifier)
```

- [ ] `terraform.tfvars` existe et contient `deployment_mode = "production"`
- [ ] `private_key_path` renseigné
- [ ] `terraform.tfvars` n'apparaît pas dans `git status` (gitigné)

---

## ✅ Étape 8 — Tester Terraform end-to-end

**Objectif :** Valider que Terraform peut se connecter à Snowflake et générer un plan sans erreur.

### 8.1 `terraform init`

**Action 1 — Placez-vous dans le dossier du projet** :

```powershell
cd $HOME\training\snowflake-terraform\project\01-day1-basics
```

**Action 2 — Initialisez Terraform** :

```powershell
terraform init
```

Attendu : `Terraform has been successfully initialized!`

> 🛠️ **Erreur fréquente :** `Failed to query available provider packages`
> ➜ Vérifiez votre connexion Internet. Terraform télécharge le provider Snowflake depuis le registry.

### 8.2 `terraform validate`

```powershell
terraform validate
```

Attendu : `Success! The configuration is valid.`

### 8.3 `terraform plan`

```powershell
terraform plan -no-color
```

Attendu : un plan affichant `DB_RAW_DEV`, `WH_ETL_DEV` et les schémas, **sans erreur JWT**.

> 🛠️ **Si `terraform plan` affiche `JWT token is invalid`** : vérifiez que la clé publique RSA a bien été assignée à `TERRAFORM_SVC` dans Snowflake (`HAS_KEYPAIR = true`) et que `private_key_path` pointe vers le bon fichier `snowflake_key.p8`.

### ✅ Checkpoint — Après l'Étape 8

- [ ] `terraform init` réussit (providers téléchargés)
- [ ] `terraform validate` réussit (syntaxe OK)
- [ ] `terraform plan` affiche un plan sans erreur d'authentification
- [ ] Le plan montre les ressources `DB_RAW_DEV`, `WH_ETL_DEV`, `SALES`, `FINANCE`

---

## 🧹 Étape 9 — Vérifier `.gitignore`

**Objectif :** S'assurer qu'aucun secret ne peut être commité par erreur.

**Action 1 — Ouvrez le fichier `.gitignore` à la racine du repo** :

```powershell
code .gitignore
```

Le fichier doit contenir **au minimum** les entrées suivantes (le fichier réel du repo est plus complet) :

```text
# Terraform
.terraform/
.terraform-plugins/
*.tfstate
*.tfstate.*
*.tfplan
tfplan
capstone.tfplan
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Secrets
secrets/
*.p8
*.pem
*.pub
access.txt
*.tfvars
backend.hcl

# Generated
generated*.tf
graph.dot
graph.png
outputs.json
schema.json

# IDE
.idea/
.vscode/settings.json

# OS
Thumbs.db
.DS_Store

# Tools (local binaries)
tools/tf-bin/
tools/*.zip
tools/*.fdmdownload
```

> ⚠️ **Note :** `.terraform.lock.hcl` n'est **pas** dans le `.gitignore` — il doit être commité pour garantir la reproductibilité des versions de providers.

**Action 2 — Testez qu'aucun secret n'est visible par Git** :

```powershell
git status --short
```

Aucun fichier `secrets/`, `*.tfvars`, `access.txt`, `*.p8`, `*.pub` ne doit apparaître.

---

## 🔍 Checklist de vérification finale

| # | Vérification | Commande | Résultat attendu |
|---|---|---|---|
| 1 | Terraform OK | `terraform version` | `v1.14.5` |
| 2 | `snow` OK | `snow --version` | `3.x.x` |
| 3 | OpenSSL OK | `openssl version` | `3.x.x` |
| 4 | Clé PKCS#8 OK | `Get-Content secrets\snowflake_key.p8 -First 1` | `-----BEGIN PRIVATE KEY-----` |
| 5 | Clé oneline OK | `Test-Path secrets\snowflake_key.oneline` | `True` |
| 6 | Connexion admin OK | `snow connection test -c admin` | `OK` |
| 7 | `TERRAFORM_SVC` avec clé | `snow sql -c admin -q "DESC USER TERRAFORM_SVC"` | `HAS_KEYPAIR: true` |
| 8 | Connexion JWT OK | `snow sql -c terraform_svc -q "SELECT current_user()"` | `TERRAFORM_SVC` |
| 9 | Init OK | `terraform init` | `successfully initialized` |
| 10 | Validate OK | `terraform validate` | `Success!` |
| 11 | Plan OK | `terraform plan` | Plan sans erreur |
| 12 | `.gitignore` OK | `git status --short` | Aucun secret visible |
| 13 | `config.toml` OK | `Get-Content $env:LOCALAPPDATA\snowflake\config.toml` | 2 sections : `admin` + `terraform_svc` |
| 14 | `config.toml` hors Git | `git status --short` | `config.toml` n'apparaît pas |

---

## Troubleshooting

### `terraform : The term 'terraform' is not recognized`

```powershell
# Vérifiez où Terraform est installé
where.exe terraform

# Si terraform n'est pas dans le PATH mais existe dans tools/tf-bin :
$env:PATH = "$PWD\tools\tf-bin;" + $env:PATH
terraform version
```

Si ça marche, ré-ajoutez au PATH utilisateur via `SystemPropertiesAdvanced` ou PowerShell :

```powershell
[Environment]::SetEnvironmentVariable(
  "PATH",
  "$PWD\tools\tf-bin;$([Environment]::GetEnvironmentVariable('PATH','User'))",
  "User"
)
```

### `snow connection test -c admin` échoue

Vérifiez que vous utilisez JWT (pas de mot de passe) :
- `account = <snowflake-account>`
- `host = <snowflake-organization>-<snowflake-account>.snowflakecomputing.com`
- `user = DATA2AI`
- `authenticator = SNOWFLAKE_JWT`
- `private_key_file = ...\\secrets\\snowflake_key.p8`
- `role = ACCOUNTADMIN`
- La clé publique RSA a bien été assignée à `DATA2AI` dans Snowsight (`HAS_KEYPAIR = true`)

#### Erreur : `MFA with TOTP is required` ou `MFA authentication is required`

Si vous obtenez :
```
250001 (08001): Failed to connect to DB: ... MFA with TOTP is required.
390190 (08001): ... MFA authentication is required, but none of your current MFA methods are supported for programmatic authentication.
```

Le compte `DATA2AI` a l'authentification MFA enforced par le bundle `2024_08` de Snowflake. La CLI `snow` ne supporte pas l'authentification MFA programmatique.

> ✅ **Solution recommandée — Utiliser JWT key-pair pour `DATA2AI` aussi**
>
> Au lieu de fighting MFA, assignez la clé publique RSA à `DATA2AI` et utilisez JWT pour la connexion admin. Cela contourne MFA entièrement — pas besoin de désactiver quoi que ce soit.

**Étape 1 — Assignez la clé publique à `DATA2AI` depuis Snowsight**

1. Connectez-vous à **https://app.snowflake.com** en tant que `DATA2AI` (avec MFA dans le navigateur)
2. Ouvrez un **SQL Worksheet** et exécutez :

```sql
-- Assigner la clé publique RSA à l'utilisateur admin
-- (contenu de secrets/snowflake_key.oneline)
ALTER USER DATA2AI SET RSA_PUBLIC_KEY = '<collez le contenu de secrets/snowflake_key.oneline>';

-- Vérifier
DESCRIBE USER DATA2AI;
-- HAS_KEYPAIR doit être true
```

**Étape 2 — Recréez la connexion admin en JWT**

```powershell
# Supprimer l'ancienne connexion admin (mot de passe)
snow connection remove admin

# Créer la connexion admin avec JWT (pas de MFA)
snow connection add -n admin `
  -a "<snowflake-account>" `
  -h "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com" `
  -u "<SNOWFLAKE_ADMIN_USER>" `
  -r "<SNOWFLAKE_ROLE>" `
  -A "SNOWFLAKE_JWT" `
  -k "$PWD\secrets\snowflake_key.p8" `
  --no-interactive

# Tester — doit retourner OK
snow connection test -c admin
```

**Étape 3 — Créez `TERRAFORM_SVC` avec `snow` (maintenant que admin fonctionne)**

```powershell
# Récupérer la clé publique oneline
$pubKey = (Get-Content secrets\snowflake_key.pub | Where-Object { $_ -notmatch 'BEGIN|END' }) -join ''

# Créer l'utilisateur service
snow sql -c admin -q "
CREATE USER IF NOT EXISTS TERRAFORM_SVC
  TYPE = SERVICE
  DEFAULT_ROLE = ACCOUNTADMIN
  RSA_PUBLIC_KEY = '$pubKey';

GRANT ROLE ACCOUNTADMIN TO USER TERRAFORM_SVC;
"

# Vérifier
snow sql -c admin -q "DESCRIBE USER TERRAFORM_SVC" 2>&1 | Select-String "HAS_KEYPAIR|RSA_PUBLIC_KEY"
# Attendu : HAS_KEYPAIR | true
```

**Étape 4 — Créez la connexion `terraform_svc` en JWT**

```powershell
snow connection add -n terraform_svc `
  -a "<snowflake-account>" `
  -h "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com" `
  -u "<SNOWFLAKE_TERRAFORM_USER>" `
  -r "<SNOWFLAKE_ROLE>" `
  -A "SNOWFLAKE_JWT" `
  -k "$PWD\secrets\snowflake_key.p8" `
  --no-interactive

# Tester — doit retourner OK
snow connection test -c terraform_svc
```

**Étape 5 — Vérifiez le `config.toml` final**

```powershell
Get-Content "$env:LOCALAPPDATA\snowflake\config.toml"
```

Attendu :
```toml
[connections.admin]
account = "<snowflake-account>"
host = "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com"
user = "DATA2AI"
role = "ACCOUNTADMIN"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "...\\secrets\\snowflake_key.p8"

[connections.terraform_svc]
account = "<snowflake-account>"
host = "<snowflake-organization>-<snowflake-account>.snowflakecomputing.com"
user = "TERRAFORM_SVC"
role = "ACCOUNTADMIN"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "...\\secrets\\snowflake_key.p8"
```

**Résumé** :

| Étape | Action | Checkpoint |
|---|---|---|
| 1 | Assigner clé publique à `DATA2AI` dans Snowsight | `HAS_KEYPAIR = true` |
| 2 | Recréer connexion admin en JWT | `snow connection test -c admin` → OK |
| 3 | Créer `TERRAFORM_SVC` avec `snow sql` | `HAS_KEYPAIR = true` pour `TERRAFORM_SVC` |
| 4 | Créer connexion `terraform_svc` en JWT | `snow connection test -c terraform_svc` → OK |
| 5 | Vérifier `config.toml` | 2 sections `[connections.*]` avec `SNOWFLAKE_JWT` |

> ⚠️ **Sécurité :** Snowflake déprécie l'authentification par mot de passe seul. L'approche JWT key-pair est la **méthode recommandée** pour l'accès programmatique. MFA reste active pour les connexions navigateur (Snowsight).

### `config.toml` introuvable ou vide

Si `snow` ne trouve pas `config.toml` :

```powershell
# Vérifiez l'emplacement (Snowflake CLI 3.25+)
Test-Path "$env:LOCALAPPDATA\snowflake\config.toml"

# Ancien emplacement (versions < 3.25)
Test-Path "$HOME\.snowflake\config.toml"

# Si le dossier n'existe pas, créez-le
New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\snowflake" -Force

# Puis relancez une commande snow pour générer le fichier
snow --help
```

### `config.toml` commité par erreur dans Git

Si `config.toml` apparaît dans `git status` :

```powershell
# Le fichier est dans AppData\Local\snowflake\ (ou ~/.snowflake/), normalement hors du repo
# Si vous avez copié config.toml dans le repo par erreur :
git rm --cached config.toml
# Ajoutez au .gitignore :
Add-Content .gitignore "`nconfig.toml"
```

### `snow connection test -c terraform_svc` = `JWT token is invalid`

1. Vérifiez que `snowflake_key.p8` correspond à `snowflake_key.pub`.
2. Vérifiez que la clé publique de `TERRAFORM_SVC` dans Snowflake est bien celle de `snowflake_key.pub`.
3. Si après ces vérifications l'erreur persiste, vérifiez que l'utilisateur `TERRAFORM_SVC` a bien `TYPE = SERVICE` (les utilisateurs service n'ont pas de MFA).

### `terraform plan` = `JWT token is invalid`

Même diagnostic que ci-dessus. Puis :

```powershell
# Vérifier le chemin de la clé
Test-Path (Resolve-Path "../../secrets/snowflake_key.p8")

# Vérifier provider.tf
Get-Content provider.tf
```

### `Error: Conflicting configuration arguments` (private_key vs password)

Le `provider.tf` du projet utilise le pattern `deployment_mode` qui sélectionne automatiquement JWT **ou** password via des conditions ternaires. Si vous obtenez cette erreur, c'est que vous avez ajouté manuellement `private_key` et `password` en même temps. **Ne modifiez pas `provider.tf`** — contrôlez l'authentification via la variable `deployment_mode` dans `terraform.tfvars` uniquement.

### `terraform.tfvars` commité par erreur

```powershell
git rm --cached terraform.tfvars
git commit -m "Remove committed terraform.tfvars"
# Ajoutez *.tfvars dans .gitignore si ce n'est pas déjà fait
```

---

## Validation et auto-évaluation

1. Quelle est la différence entre un utilisateur humain (`DATA2AI`) et un utilisateur service (`TERRAFORM_SVC`) ?
   <details><summary>Réponse</summary>L'utilisateur service est dédié aux outils et automatisations ; il doit avoir le minimum de privilèges et être authentifié par mécanisme machine (JWT).</details>

2. Pourquoi JWT key-pair est-elle recommandée en production ?
   <details><summary>Réponse</summary>Pas de mot de passe statique à stocker ou transmettre ; chaque connexion est signée par une clé privée et expire rapidement.</details>

3. Que faire si `terraform plan` retourne `JWT token is invalid` ?
   <details><summary>Réponse</summary>Vérifier la correspondance clé privée/clé publique, vérifier que `HAS_KEYPAIR = true` pour `TERRAFORM_SVC`, et que `private_key_path` pointe vers le bon fichier.</details>

---

## 🚀 Challenge optionnel

1. Créez un second utilisateur `TERRAFORM_SVC_TEST` avec un rôle moins privilégié que `ACCOUNTADMIN` (par exemple `SYSADMIN`).
2. Générez une seconde paire de clés et testez la connexion JWT avec ce nouvel utilisateur.
3. Documentez dans un fichier `notes.md` personnel les différences entre les deux modes d'auth.

---

## ✅ Fin du Lab M0

Une fois la checklist verte, vous pouvez passer au **Lab M1 — Premier déploiement Terraform sur Snowflake**. Tous les modules suivants supposent que `terraform init` + `terraform plan` fonctionnent dans `project/01-day1-basics`.
---

## Notes d'architecte

- **Décision :** la capacité du module est traitée comme un produit de plateforme, pas comme un exemple isolé.
- **Compromis :** le lab réduit volontairement l'échelle afin de rester exécutable en sandbox ; les contrôles de production restent obligatoires.
- **Garde-fou :** toute modification doit produire un plan relu, une validation technique et une preuve d'absence de dérive.

## Bonnes pratiques Enterprise

- Versionner les contrats et les modules, jamais les secrets ni les fichiers de state.
- Appliquer le moindre privilège aux identités humaines et techniques.
- Utiliser un state distant isolé, un artefact de plan immuable et une approbation avant production.
- Rendre sécurité, fiabilité, coût et observabilité vérifiables par le pipeline.

## Notes de production

| Dimension | Training | Production |
|---|---|---|
| Identité | Secret transmis hors Git | JWT, identité technique dédiée et rotation contrôlée |
| State | Backend simplifié ou sandbox | Azure Blob privé, chiffré, verrouillé et isolé |
| Déploiement | Exécution locale guidée | Azure DevOps, approbation et artefact de plan |
| Exploitation | Validation ponctuelle | SLO, alertes, runbooks, FinOps et contrôle continu de dérive |

## Réflexion

1. Quel risque métier réapparaît si cette capacité est gérée manuellement ?
2. Quel contrôle doit devenir obligatoire avant une promotion en production ?
3. Quelle preuve transmettre à l'équipe qui exploite la capacité suivante ?



