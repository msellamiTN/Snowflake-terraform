# Jour 0 — Concepts : environnement, outils et sécurité

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Pourquoi un Jour 0 ?

Le Jour 0 prépare votre poste pour les 5 jours de pratique. Un poste mal configuré est la première cause de perte de temps en formation. L'automatisation garantit que tous les apprenants démarrent dans le même état.

## Ce qui est installé

| Outil | Version | Rôle | Niveau |
|---|---|---|---|
| Git | latest | Versionnement et collaboration | Core |
| Terraform | 1.14.5 | Infrastructure as Code | Core |
| Python | 3.12 | Exécution de Snow CLI et dbt | Core |
| Snowflake CLI | latest stable | Connexions et SQL Snowflake | Core |
| Azure CLI | 2.83.0 | Authentification et ressources Azure | Course |
| dbt | < 3.0.0 | Transformations et FinOps | Course |
| tflint | 0.50.0 | Linter Terraform | Optional |
| VS Code | latest | Éditeur recommandé | Optional |
| OpenSSL | latest | Génération de clés RSA | Optional |

Les versions sont définies dans la [politique de versions](../../docs/version-policy.md).

## Où sont installés les outils

| Plateforme | Dossier binaire | Environnement Python |
|---|---|---|
| Windows | `$HOME\.data2ai\bin` | `$HOME\.data2ai\venv` |
| Linux/macOS | `$HOME/.data2ai/bin` | `$HOME/.data2ai/venv` |

L'installation sous le profil utilisateur évite d'avoir besoin de privilèges administrateur et isole la formation du reste du système.

## Pourquoi un environnement virtuel Python ?

Snow CLI et dbt sont des paquets Python. Les installer dans l'interpréteur global peut entrer en conflit avec d'autres projets. L'environnement virtuel isolé garantit :

- des versions reproductibles;
- aucune interférence avec d'autres projets;
- une suppression propre en fin de formation.

## Le projet type

Le projet type `data-platform-starter` est le **point d'entrée unique** de l'apprenant. Il est cloné au Jour 0 et devient la racine de travail pour toute la formation. Il contient :

- les **scripts** d'installation (`Install-Tools.ps1`, `install-tools.sh`), de connexion (`New-SnowflakeConnection.ps1`, `new-snowflake-connection.sh`) et de validation (`validate.ps1`, `validate.sh`);
- la **structure de gouvernance** (dossiers `environments/`, `modules/`, `docs/`);
- les fichiers de qualité (`.gitignore`, `.editorconfig`, `.tflint.hcl`);
- le pipeline CI/CD Azure DevOps;
- la documentation (architecture, conventions, runbook, ADR);
- la propriété du code (`CODEOWNERS`).

Il **ne fournit pas** le code Terraform. Vous créerez les fichiers `.tf` au fil des modules, en suivant les ateliers du Jour 1 au Jour 5. Tous les fichiers que vous créerez iront dans ce clone.

## Authentification Snowflake

### PAT (Personal Access Token)

Le PAT est un jeton temporaire utilisé pour la formation. Il est :

- saisi via une invite masquée — jamais affiché;
- stocké par Snowflake CLI dans sa configuration;
- jamais placé dans un fichier du dépôt;
- effacé de l'environnement dès que possible par le script de connexion.

### Progression d'authentification

| Étape | Méthode | Raison |
|---|---|---|
| Jour 0 à Jour 3 | PAT temporaire | Démarrer sans friction |
| Jour 4 et au-delà | JWT key-pair avec Key Vault | Pratique de production |
| CI/CD | Fédération d'identité Azure | Aucun secret en clair |

## Règles de sécurité

1. **Aucun secret dans le dépôt.** Le `.gitignore` exclut `.env`, `secrets/`, clés, jetons et `tfvars`.
2. **Le PAT est temporaire.** Il doit être rotationné après la formation.
3. **Aucun `ACCOUNTADMIN` comme correction générique.** Le rôle `SYSADMIN` suffit pour la formation.
4. **Aucune ressource Cloud créée au Jour 0.** Le Jour 0 prépare le poste, pas l'infrastructure.

## Ce que le script a fait (résumé)

1. Vérifié les outils déjà installés.
2. Téléchargé et installé les outils manquants sous votre profil.
3. Créé un environnement virtuel Python pour Snow CLI et dbt.
4. Ajouté les dossiers d'installation à votre PATH.
5. Vérifié les versions attendues.
6. Généré un rapport Markdown et JSON sans aucune valeur secrète.

## Suite

Passez à l'[atelier pratique](../module-00-tools-setup/lab.md) pour exécuter les scripts.
