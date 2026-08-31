# Module M0 — Cours : Préparation de l'environnement

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

---

## 1. Pourquoi un lab dédié à la préparation ?

Avant d'écrire la moindre ressource Terraform, le poste de travail doit être **reproductible** : même version d'outils, mêmes chemins, mêmes credentials. Un étudiant qui arrive avec un PATH incomplet ou une mauvaise version du provider passera 30 minutes à débugger avant de voir son premier `terraform apply` réussi.

Ce module M0 a trois objectifs pédagogiques :
1. **Vérifier** la chaîne outils (Terraform, Snow CLI, Git, OpenSSL) — installée via l'Atelier 0.
2. **Comprendre** l'authentification Snowflake par JWT key-pair.
3. **Appliquer** les bonnes pratiques de gestion des secrets dès le premier jour.

---

## 2. Chaîne outils

### 2.1 Terraform

Terraform est un binaire unique qui lit des fichiers `.tf` et appelle les APIs cloud. La version utilisée dans cette formation est **1.14.5**.

Points clés :
- Pas d'installateur Windows officiel : on télécharge le ZIP et on extrait dans `tools/tf-bin`.
- Le `PATH` utilisateur doit être mis à jour ; un `terraform version` dans un **nouveau** terminal valide l'installation.
- Le cache de plugins (`.terraform-plugins`) évite de re-télécharger les providers à chaque `init`.

### 2.2 Snowflake CLI (`snow`)

`snow` remplace progressivement SnowSQL. Il est installé via `pip` et utilise un fichier de configuration `config.toml` (sur Windows : `%LOCALAPPDATA%\snowflake\config.toml` avec Snowflake CLI 3.25+).

Pour cette formation, on configure **deux connexions** :
- `admin` : utilisateur `DATA2AI`, authentifié par JWT key-pair (contourne MFA), utilisé pour créer `TERRAFORM_SVC`.
- `terraform_svc` : utilisateur `TERRAFORM_SVC`, authentifié par JWT key-pair, utilisé pour les tests et diagnostics.

### 2.3 OpenSSL

OpenSSL est fourni avec Git pour Windows. On l'utilise pour générer une paire de clés RSA au format PKCS#8 sans passphrase :

```powershell
# Depuis la racine du repo (pas depuis secrets/)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out secrets/snowflake_key.p8 -nocrypt
openssl rsa -in secrets/snowflake_key.p8 -pubout -out secrets/snowflake_key.pub
```

> Si `openssl` n'est pas dans le PATH, utilisez le chemin complet :
> `& "C:\Program Files\Git\mingw64\bin\openssl.exe" genrsa 2048 | ...`

Pourquoi PKCS#8 sans passphrase ?
- Le provider Terraform `snowflakedb/snowflake` attend un fichier PEM lisible.
- Une passphrase obligerait à la stocker quelque part, ce qui contredirait l'objectif de sécurité.

---

## 3. Authentification Snowflake

### 3.1 Password authentication (legacy)

L'utilisateur envoie son login + mot de passe. Simple, mais problématique pour l'IaC :
- Le mot de passe transite à chaque exécution.
- Il doit être stocké (variable d'environnement, fichier tfvars, vault).
- Difficile à rotate sans interruption.
- **MFA enforced** par Snowflake (bundle `2024_08`) — les connexions programmatiques par mot de passe échouent.

> ⚠️ L'authentification par mot de passe **n'est plus utilisée** dans cette formation. Le `provider.tf` conserve un mode `training` pour compatibilité legacy, mais le lab utilise exclusivement JWT key-pair.

### 3.2 JWT key-pair authentication

JWT (*JSON Web Token*) est un token signé qui prouve l'identité de l'émetteur.

```mermaid
sequenceDiagram
    participant T as Terraform
    participant S as Snowflake
    T->>T: Lit snowflake_key.p8
    T->>T: Construit JWT signé avec clé privée
    T->>S: POST /session/v1/login-request + JWT
    S->>S: Vérifie signature avec RSA_PUBLIC_KEY de TERRAFORM_SVC
    S-->>T: Session token
```

Le JWT contient :
- `sub` : identifiant du compte + utilisateur.
- `iat` / `exp` : validité courte (généralement 60 secondes).
- Signature RSA-SHA256.

Avantages en production :
- Pas de mot de passe dans le code.
- Rotation simple : générer une nouvelle paire, mettre à jour la clé publique côté Snowflake.
- Tracabilité : chaque connexion est authentifiée par une clé unique.

### 3.3 Formats de clés

| Format | Fichier | Usage |
|---|---|---|
| PKCS#1 | `-----BEGIN RSA PRIVATE KEY-----` | Ancien format RSA ; compatible avec la plupart des outils. |
| PKCS#8 | `-----BEGIN PRIVATE KEY-----` | Format générique recommandé ; utilisé par Terraform dans cette formation. |
| SPKI | `-----BEGIN PUBLIC KEY-----` | Format de la clé publique à charger dans Snowflake. |

Snowflake attend la clé publique en **base64 sans marqueurs** pour `RSA_PUBLIC_KEY`.

---

## 4. Gestion des secrets

### 4.1 Secrets à protéger

- `secrets/snowflake_key.p8`
- `secrets/snowflake_key.pub`
- `access.txt`
- Tous les `terraform.tfvars` (contiennent des identifiants Snowflake)

### 4.2 Mécanismes de protection

1. **`.gitignore`** : empêche le commit.
2. **Chemins relatifs** : les labs utilisent `../../secrets/...` ou `../../../../secrets/...` selon la profondeur.
3. **Variables `sensitive = true`** : dans `variables.tf`, `snowflake_password` et `private_key_path` sont marquées sensibles.
4. **Jamais de secret dans `provider.tf`** : la clé est injectée via `file(var.private_key_path)`.

### 4.3 En production

- Stocker la clé privée dans un vault (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault).
- Utiliser `SNOWFLAKE_PRIVATE_KEY` via variables d'environnement sécurisées dans la CI/CD.
- Rotation programmée : clé publique secondaire (`RSA_PUBLIC_KEY_2`) pendant la transition.

---

## 5. Configuration du provider Terraform

### 5.1 JWT key-pair (utilisé dans ce lab)

```hcl
provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  role              = var.snowflake_role
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(var.private_key_path)
}
```

### 5.2 Password fallback (legacy, non utilisé)

Le `provider.tf` du projet conserve un mode `training` avec mot de passe pour compatibilité, mais il **n'est pas utilisé** dans cette formation. MFA enforced par Snowflake rend les connexions programmatiques par mot de passe impossibles.

> ⚠️ `private_key` et `password` sont mutuellement exclusifs. Le lab utilise `private_key` uniquement.

---

## 6. Différence formation vs production

| Aspect | Formation (ce repo) | Production recommandé |
|---|---|---|
| Utilisateur | `DATA2AI` (admin) + `TERRAFORM_SVC` (service) | Utilisateur service dédié par application/pipeline |
| Auth | JWT key-pair pour les deux | JWT key-pair obligatoire |
| Clé privée | `secrets/snowflake_key.p8` local | Vault / variable CI chiffrée |
| Rotation | Manuelle | Automatisée via `RSA_PUBLIC_KEY_2` |
| tfvars | Local, gitignoré | Aucun ; tout passe par vault/env |

---

## 7. Checklist mentale du formateur

Avant chaque session :
1. Vérifier que `access.txt` est présent et lisible.
2. Vérifier que `secrets/` contient `snowflake_key.p8`.
3. Tester `snow connection test -c admin`.
4. Tester `terraform plan` dans `project/01-day1-basics`.
5. Si le JWT est rejeté, vérifier que `HAS_KEYPAIR = true` pour `DATA2AI` et `TERRAFORM_SVC` dans Snowflake.

---

## 8. Ressources complémentaires

- [Snowflake Docs — Key-Pair Authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth)
- [Terraform Snowflake Provider](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs)
- [OpenSSL genrsa / pkcs8 man pages](https://www.openssl.org/docs/)


