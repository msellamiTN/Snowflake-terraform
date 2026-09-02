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

### PAT (Personal Access Token) - CLI et Terraform

Le PAT est un jeton temporaire utilisé pour la formation. Le flux est :

1. le **formateur** pré-remplit `.env.example` avec les identifiants Snowflake, Azure et Azure DevOps;
2. l'**apprenant** copie `.env.example` en `.env` et ajoute son préfixe et son PAT;
3. le **script de connexion** lit `.env` automatiquement et crée la connexion Snowflake CLI;
4. le PAT est jamais affiché, jamais stocké dans un fichier commité;
5. le script efface le token de l'environnement dès que possible.

### Username + Password - Interface web

Le PAT ne fonctionne pas pour l'interface web `app.snowflake.com`. Pour permettre
aux apprenants de vérifier visuellement leurs ressources, le formateur crée des
**utilisateurs Snowflake individuels** avec mots de passe.

Le flux est :

1. le **formateur** exécute `Add-SnowflakeLearners.ps1` (ou `add-snowflake-learners.sh`);
2. le script crée 10 utilisateurs (`apprenant01` à `apprenant10`) avec rôle `SYSADMIN`;
3. les mots de passe respectent la politique Snowflake (14+ caractères, 1 chiffre, 1 majuscule, 1 minuscule);
4. les mots de passe sont sauvegardés dans `secrets/learner-snowflake-passwords.txt` (gitignored);
5. le **formateur** distribue chaque mot de passe à l'apprenant correspondant;
6. l'**apprenant** se connecte à `https://app.snowflake.com` avec son username + password.

> `[NOTE]` Le PAT (CLI/Terraform) et le password (web) sont deux méthodes d'authentification
> distinctes pour le même compte Snowflake. L'apprenant utilise les deux selon le contexte.

## Authentification Azure

### Service principal partagé

Azure enforce MFA depuis septembre 2025, ce qui bloque `az login -u -p` en CLI.
Pour contourner ce blocage en formation, un **service principal partagé** est utilisé.

Le flux est :

1. le **formateur** crée un SP `sp-data2ai-learners` avec rôle `Contributor`;
2. le **formateur** génère un secret et le sauvegarde dans `secrets/shared-sp.txt`;
3. l'**apprenant** exécute `Learner-Login.ps1 -LearnerPrefix APP01` (ou `learner-login.sh APP01`);
4. le script se connecte à Azure avec le SP (pas de MFA);
5. les variables `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` sont définies;
6. `LEARNER_PREFIX` est défini pour l'isolation des ressources.

> `[IMPORTANT]` Relancer `Learner-Login` au début de chaque nouvelle session (nouveau terminal, redémarrage VM).

### Progression d'authentification

| Étape | Méthode | Raison |
|---|---|---|
| Jour 0 à Jour 3 | PAT temporaire (Snowflake) + SP partagé (Azure) | Démarrer sans friction, contourner MFA |
| Jour 4 et au-delà | JWT key-pair avec Key Vault | Pratique de production |
| CI/CD | Fédération d'identité Azure (WIF) | Aucun secret en clair |

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
