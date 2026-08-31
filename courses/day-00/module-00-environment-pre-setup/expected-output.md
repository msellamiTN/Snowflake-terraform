# Résultat attendu — M0 : Préparation de l'environnement

## Vérification de la chaîne d'outils

### Terraform
```bash
terraform version
```
**Attendu :**
```
Terraform v1.14.5
```

### Snowflake CLI
```bash
snow --version
```
**Attendu :**
```
Snow CLI version 2.5.0 (ou ultérieure)
```

### Azure CLI
```bash
az version
```
**Attendu :**
```
azure-cli 2.83.0 (ou ultérieure)
```

## Test de connexion

### Authentification JWT Snowflake (Production)
```bash
snow sql -q "SELECT CURRENT_USER(), CURRENT_ROLE()" --connection training
```
**Attendu :**
```
+-----------------+------------------+
| CURRENT_USER()  | CURRENT_ROLE()   |
+-----------------+------------------+
| TERRAFORM_SVC   | SYSADMIN         |
+-----------------+------------------+
```

### Authentification par mot de passe (Formation)
```bash
snow sql -q "SELECT CURRENT_USER(), CURRENT_ROLE()" --connection training
```
**Attendu :**
```
+-----------------+------------------+
| CURRENT_USER()  | CURRENT_ROLE()   |
+-----------------+------------------+
| DATA2AI         | SYSADMIN         |
+-----------------+------------------+
```

## Identité d'équipe

Chaque participant reçoit un code d'équipe (ex. `TEAM01`, `TEAM02`). Toutes les ressources utiliseront ce code comme préfixe.

**État attendu :**
- Code d'équipe enregistré dans `terraform.tfvars` via la variable `team`
- Répertoire de travail : `d:\Formation\Wevops\C10-CDevpos\Terraform`
- `secrets/snowflake_key.p8` existe (si JWT) OU mot de passe dans `terraform.tfvars` (si fallback)

## Comptage des ressources

Aucune ressource Terraform créée dans M0. Ce module est uniquement de configuration.

| Vérification | Attendu |
|--------------|---------|
| Terraform installé | v1.14.5 |
| Snow CLI installé | latest |
| Azure CLI installé | 2.83.0+ |
| Connexion Snowflake | JWT ou mot de passe fonctionne |
| Code d'équipe attribué | Unique par participant |
| Fichier de clé (si JWT) | `secrets/snowflake_key.p8` existe, PKCS#8, sans passphrase |

