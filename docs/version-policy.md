# Politique de versions

Ce document est la **source de vérité** des versions utilisées par la formation. Elles reproduisent l'environnement de production afin que le code appris soit directement transposable.

> Règle : aucun support ne redéfinit une version localement. Toute divergence constatée est un défaut à corriger ici puis dans le code.

## Terraform et providers

| Composant | Version | Contrainte HCL | Rôle |
|---|---|---|---|
| Terraform CLI | 1.14.5 | `= 1.14.5` | Moteur Infrastructure as Code |
| `snowflakedb/snowflake` | 2.14.0 | `= 2.14.0` | Objets Snowflake |
| `hashicorp/azurerm` | 4.59.0 | `= 4.59.0` | Backend state et Key Vault |
| `microsoft/azuredevops` | 1.14.0 | `= 1.14.0` | Pipelines CI/CD as Code |
| `hashicorp/tls` | >= 4.0 | `>= 4.0` | Génération de clés RSA |

### Pourquoi un épinglage strict

Une contrainte souple comme `~> 2.14.0` autorise la résolution automatique d'un correctif, par exemple 2.14.1. Deux apprenants peuvent alors obtenir des comportements différents pour le même code. En formation comme en production, le fichier `.terraform.lock.hcl` et une contrainte exacte garantissent un résultat identique.

## Outils complémentaires

| Outil | Version | Usage |
|---|---|---|
| Python | 3.12 | Exécution de Snow CLI et dbt |
| Snowflake CLI (`snow`) | Dernière version stable | Connexions, SQL et publication d'objets |
| Azure CLI | 2.83.0 | Authentification et interactions Azure |
| dbt-core | `< 3.0.0` | Transformations et FinOps |
| dbt-snowflake | `< 3.0.0` | Adaptateur Snowflake |

## Packages dbt

| Package | Version | Source |
|---|---|---|
| `get-select/dbt_snowflake_monitoring` | 4.6.0 | dbt Hub |
| `dbt-labs/dbt_utils` | 1.3.3 | dbt Hub |

> Le package de monitoring s'appelle bien `get-select/dbt_snowflake_monitoring`. Tout autre identifiant fait échouer `dbt deps`.

## Vérification sur un poste

### Windows

```powershell
terraform version
snow --version
az version
python --version
dbt --version
```

### Linux/macOS

```bash
terraform version
snow --version
az version
python3 --version
dbt --version
```

## Vérification dans le code

```text
terraform init
terraform providers
```

La sortie doit afficher exactement les versions du tableau ci-dessus. Si `terraform init` installe une version différente, la contrainte du fichier `versions.tf` est trop permissive.

## Procédure de mise à jour

Une montée de version n'est jamais faite pendant une session de formation.

1. Ouvrir une branche dédiée.
2. Lire les notes de version, notamment les changements incompatibles du provider Snowflake.
3. Mettre à jour ce document en premier.
4. Mettre à jour les fichiers `versions.tf` et les fichiers de verrouillage.
5. Exécuter `fmt`, `validate` et `plan` sur toutes les racines.
6. Vérifier qu'aucun plan ne propose de destruction inattendue.
7. Exécuter le pipeline complet.
8. Mettre à jour les sorties attendues des supports concernés.

## Fonctions preview du provider Snowflake

Certaines ressources nécessitent `preview_features_enabled`. Elles peuvent évoluer sans changement de version majeure. Toute ressource preview utilisée dans un support doit être explicitement signalée comme telle.
