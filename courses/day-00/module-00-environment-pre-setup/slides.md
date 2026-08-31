# Module M0 — Slides : Préparation de l'environnement

---

## Slide 1 — Titre

**Industrialisation Data Platform — Jour 0**  
Module M0 : Préparation de l'environnement  
*Durée : 2h00*

---

## Slide 2 — Pourquoi un Jour 0 ?

Objectifs :
- Éviter les erreurs de version d'outils.
- Aligner tous les postes sur le même workflow.
- Maîtriser l'authentification avant de déployer quoi que ce soit.

> Un étudiant qui perd 45 minutes sur son PATH ou sur son JWT perdra le fil du Jour 1.

---

## Slide 3 — Stack outils

| Outil | Rôle | Version |
|---|---|---|
| Terraform | Moteur IaC | 1.14.5 |
| Snowflake CLI (`snow`) | Interaction Snowflake | 3.x |
| OpenSSL | Génération clés RSA | 3.x |
| Git | Versioning | latest |
| VS Code + extension Terraform | IDE | latest |

Installation : ZIP + mise à jour du `PATH` utilisateur.

---

## Slide 4 — Schéma du workflow M0

```mermaid
flowchart TD
    A[Outils installés] --> B[Clés RSA générées]
    B --> C[TERRAFORM_SVC créé]
    C --> D{JWT OK ?}
    D -->|Oui| E[Provider JWT]
    D -->|Non| F[Fallback DATA2AI password]
    E --> G[terraform plan OK]
    F --> G
```

---

## Slide 5 — Authentification : password vs JWT

| Critère | Password | JWT key-pair |
|---|---|---|
| Secret transité | Oui, à chaque exécution | Non, token signé |
| Stockage | Vault / variable | Fichier PEM / Vault |
| Rotation | Changement manuel | Clé publique secondaire |
| Recommandation | Fallback | Production |

---

## Slide 6 — Comment fonctionne le JWT ?

```mermaid
sequenceDiagram
    participant T as Terraform
    participant S as Snowflake
    T->>T: Lit snowflake_key.p8
    T->>T: Signe un JWT avec RSA-SHA256
    T->>S: JWT + request
    S->>S: Vérifie avec RSA_PUBLIC_KEY
    S-->>T: Session
```

- Token court (60s).
- Aucun mot de passe.
- Vérification côté Snowflake avec la clé publique de l'utilisateur.

---

## Slide 7 — Génération des clés

```powershell
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out secrets/snowflake_key.p8 -nocrypt
openssl rsa -in secrets/snowflake_key.p8 -pubout -out secrets/snowflake_key.pub
```

Formats :
- **PKCS#8** : `-----BEGIN PRIVATE KEY-----` → utilisé par Terraform.
- **SPKI** : `-----BEGIN PUBLIC KEY-----` → chargée dans Snowflake.

> ⚠️ Ne pas utiliser de passphrase pour ce lab (gère la complexité dès le Jour 0).

---

## Slide 8 — Création de TERRAFORM_SVC

```sql
CREATE USER IF NOT EXISTS TERRAFORM_SVC
  DEFAULT_ROLE = ACCOUNTADMIN
  RSA_PUBLIC_KEY = '<contenu sans marqueurs>';

GRANT ROLE ACCOUNTADMIN TO USER TERRAFORM_SVC;
```

Vérification :

```sql
DESCRIBE USER TERRAFORM_SVC;
-- HAS_KEYPAIR : true
```

---

## Slide 9 — Double piste d'authentification

**Piste A — JWT (cible)**
```hcl
authenticator = "SNOWFLAKE_JWT"
private_key   = file(var.private_key_path)
```

**Piste B — Password fallback**
```hcl
authenticator = "snowflake"
password      = var.snowflake_password
```

> Si le compte Snowflake rejette le JWT malgré une configuration correcte, on bascule sur `DATA2AI` password. Cela arrive sur certains essais/sandbox.

---

## Slide 10 — Gestion des secrets

Secrets à ne **jamais** committer :
- `secrets/snowflake_key.p8`
- `secrets/snowflake_key.pub`
- `access.txt`
- `*.tfvars`

`.gitignore` minimal :
```text
secrets/
*.p8
*.pub
*.tfvars
access.txt
.terraform/
*.tfstate
```

---

## Slide 11 — Profondeur des chemins

| Module | `private_key_path` relatif |
|---|---|
| `01-day1-basics` | `../../secrets/snowflake_key.p8` |
| `02-day1-state` | `../../secrets/snowflake_key.p8` |
| `03-day2-modules/environments/dev` | `../../../../secrets/snowflake_key.p8` |
| `04-day3-rbac/environments/dev` | `../../../../secrets/snowflake_key.p8` |
| `05-capstone/environments/dev` | `../../../../secrets/snowflake_key.p8` |

> Erreur #1 dans ce lab : un mauvais chemin relatif.

---

## Slide 12 — Checklist finale

Avant de passer au Jour 1 :
1. `terraform version` → 1.14.5
2. `snow connection test -c admin` → OK
3. `snow sql -c terraform_svc -q "SELECT current_user()"` → `TERRAFORM_SVC`
4. `terraform plan` dans `01-day1-basics` → plan sans erreur
5. `git status` → aucun fichier sensible en attente

---

## Slide 13 — Rappel

- **JWT = production, password = fallback training.**
- **TERRAFORM_SVC = utilisateur dédié.**
- **DATA2AI = uniquement pour bootstrap.**
- **Aucun secret dans Git.**

Bonne préparation = formation sereine.

