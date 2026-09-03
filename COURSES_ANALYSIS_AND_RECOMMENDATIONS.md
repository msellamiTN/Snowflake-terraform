# 📑 Audit Pédagogique & Plan de Recommandations Opérationnelles
## Cursus : Terraform · Snowflake · Microsoft Azure · Azure DevOps
### Filière Académique & Professionnelle en Autoformation (80% Labs / 20% Micro-Théorie)

---

> **Auteur :** Expert Instructor & Lead Platform Architect (Terraform, Snowflake, Azure, DevOps)  
> **Cible :** Apprenants en autoformation autonome (*Self-Paced Learners*)  
> **Socle Industriel Obligatoire :** Terraform (HCL), Snowflake Enterprise (Compte & Snowsight), Microsoft Azure (Blob, Key Vault, ADLS Gen2), Azure DevOps (Repos, Pipelines, Approval Gates).  
> **Fichier de référence :** [`COURSES_ANALYSIS_AND_RECOMMENDATIONS.md`](COURSES_ANALYSIS_AND_RECOMMENDATIONS.md)

---

## 📑 Table des Matières
1. [Vision Globale & Principes d'Ingénierie Pédagogique](#1-vision-globale--principes-dingénierie-pédagogique)
2. [L'Expérience Hybride : Terminal CLI & Consoles Web](#2-lexpérience-hybride--terminal-cli--consoles-web)
3. [Standard Universel d'un Lab d'Autoformation (80% Pratique)](#3-standard-universel-dun-lab-dautoformation-80-pratique)
4. [Analyse Détaillée & Recommandations Module par Module (M00 à M14)](#4-analyse-détaillée--recommandations-module-par-module-m00-à-m14)
   - [Jour 0 : M00 — Setup & Audit d'Environnement](#jour-0--m00--setup--audit-denvironnement)
   - [Jour 1 : M01 — Premier Déploiement & Idempotence](#jour-1--m01--premier-déploiement--idempotence)
   - [Jour 1 : M02 — State Distant Azure Blob Storage & Verrouillage](#jour-1--m02--state-distant-azure-blob-storage--verrouillage)
   - [Jour 1 : M03 — Brownfield Import & Alignement de Dérive](#jour-1--m03--brownfield-import--alignement-de-dérive)
   - [Jour 1 : M04 — Variables, Validations FinOps & Outputs](#jour-1--m04--variables-validations-finops--outputs)
   - [Jour 2 : M05 — Modules Réutilisables & Landing Zone](#jour-2--m05--modules-réutilisables--landing-zone)
   - [Jour 2 : M06 — Logique Dynamique & Meta-Arguments (for_each)](#jour-2--m06--logique-dynamique--meta-arguments-for_each)
   - [Jour 2 : M07 — Pipeline CI/CD Azure DevOps](#jour-2--m07--pipeline-cicd-azure-devops)
   - [Jour 2 : M08 — Stratégie Multi-Environnements (DEV/UAT/PROD)](#jour-2--m08--stratégie-multi-environnements-devuatprod)
   - [Jour 3 : M09 — Ingestion ADLS Gen2 & External Stages](#jour-3--m09--ingestion-adls-gen2--external-stages)
   - [Jour 3 : M10 — Identité Technique, Clés RSA & Azure Key Vault](#jour-3--m10--identité-technique-clés-rsa--azure-key-vault)
   - [Jour 4 : M11 — RBAC as Code & Moindre Privilège](#jour-4--m11--rbac-as-code--moindre-privilège)
   - [Jour 4 : M12 — Projet Fil Rouge (Enterprise Capstone)](#jour-4--m12--projet-fil-rouge-enterprise-capstone)
   - [Jour 4 : M13 — FinOps & Observabilité Snowflake dbt](#jour-4--m13--finops--observabilité-snowflake-dbt)
   - [Jour 4 : M14 — Data Products, Tagging & Masquage Dynamique](#jour-4--m14--data-products-tagging--masquage-dynamique)
5. [Matrice Synthétique des Livrables & Preuves](#5-matrice-synthétique-des-livrables--preuves)
6. [Plan d'Application Opérationnel](#6-plan-dapplication-opérationnel)

---

## 1. Vision Globale & Principes d'Ingénierie Pédagogique

Pour former des ingénieurs Cloud Data & DevOps autonomes et immédiatement opérationnels, la formation doit rompre avec la documentation passive. L'apprenant en autoformation (*self-paced*) progresse par **manipulation active, observation visuelle immédiate, et diagnostic de pannes réelles**.

### Piliers Directeurs :
1. **80% Pratique Active (*Hands-On*) / 20% Micro-Théorie** :
   - Des capsules théoriques ultra-courtes (5 à 10 minutes max) illustrées par des modèles mentaux Mermaid.
   - Les 45 à 80 minutes restantes sont passées les mains sur le clavier : écriture de code HCL, exécution de scripts, navigation console, et validation.
2. **Socle Industriel Obligatoire & Non Dilué** :
   - Cœur technique : **Microsoft Azure + Terraform + Snowflake + Azure DevOps**.
   - Aucune dispersion inutile : les comparatifs AWS ou GCP restent cantonnés à des notes annexes de culture générale.
3. **Pédagogie de l'Incident (*Chaos Engineering*)** :
   - On n'apprend pas l'Infrastructure as Code uniquement quand tout fonctionne du premier coup. Chaque module intègre une étape de panne délibérée (dérive manuelle via la console web, lock d'état bloqué, permission refusée) que l'apprenant doit diagnostiquer et réparer avec un runbook structuré.
4. **Moteur d'Auto-Évaluation Automatisé (*Check My Progress*)** :
   - L'étudiant exécute `SelfPacedLab.ps1 -Module X -All` à tout moment pour recevoir un diagnostic coloré de son code et savoir exactement quoi corriger sans aide humaine.

---

## 2. L'Expérience Hybride : Terminal CLI & Consoles Web

L'apprenant dispose d'identifiants dédiés (`APP01`, `APP02`, etc.) et navigue en permanence entre son **terminal** et les **consoles web officielles** pour consolider son apprentissage :

```mermaid
flowchart TD
    subgraph TERMINAL ["💻 Terminal de l'Apprenant (CLI)"]
        TF["Terraform Engine (HCL, Plan, Apply)"]
        SNOW_CLI["Snowflake CLI (snow sql)"]
        AZ_CLI["Azure CLI (az keyvault, storage)"]
        CHECK["Moteur SelfPacedLab.ps1"]
    end

    subgraph CONSOLES ["🌐 Consoles Web Officielles (Login & Mot de Passe Apprenant)"]
        SNOW_UI["❄️ Snowflake Snowsight\n(app.snowflake.com)\nInspection SQL, Tables, Rôles & Query History"]
        AZ_PORTAL["🔵 Portail Microsoft Azure\n(portal.azure.com)\nInspection Blobs .tfstate, Key Vault & ADLS Gen2"]
        ADO_UI["🚀 Azure DevOps Portal\n(dev.azure.com)\nPull Requests, Visualisation Plan & Approval Gates"]
    end

    TERMINAL <-->|1. Déploiement & Vérification croisée| CONSOLES
    CONSOLES -.->|2. Chaos Lab : Injection manuelle de dérive (Drift)| TERMINAL
```

### Grille d'Interaction par Console Web :

| Outil Web | Identifiants Apprenant | Actions Normales de Vérification | Actions d'Injection de Panne (*Chaos Lab*) |
|---|---|---|---|
| **❄️ Snowflake Snowsight** | Compte individuel (`APP01` / mot de passe ou PAT) | - Visualiser graphiquement les bases, schemas, tables et warehouses créés par Terraform.<br/>- Inspecter le *Query History* et le profil d'exécution des requêtes.<br/>- Tester les rôles RBAC et le masquage dynamique dans les worksheets SQL. | **Création intentionnelle de dérive (*Drift*) :**<br/>Modifier un paramètre à la souris dans l'UI (ex: passer le warehouse de `X-SMALL` à `SMALL`, modifier le timeout d'auto-suspend, ajouter un commentaire) puis lancer `terraform plan` pour voir Terraform détecter l'écart. |
| **🔵 Portail Microsoft Azure** | Compte d'entreprise / Souscription dédiée | - Visualiser le conteneur Azure Blob Storage hébergeant le fichier `terraform.tfstate`.<br/>- Inspecter l'état du bail de verrouillage (*Blob Lease*).<br/>- Vérifier la présence des secrets PAT et clés privées RSA 2048 dans Azure Key Vault.<br/>- Explorer l'arborescence des fichiers Parquet dans Azure Data Lake Gen2. | **Audit d'isolation :**<br/>Vérifier visuellement que le state d'un autre apprenant n'est pas accessible et que le chiffrement au repos Azure est bien actif. |
| **🚀 Azure DevOps Web** | Compte utilisateur de formation | - Naviguer dans les dépôts Git et créer des Pull Requests.<br/>- Lire le résumé du plan Terraform généré automatiquement dans la PR.<br/>- **Cliquer sur "Approve" dans l'Environment Gate** pour autoriser le déploiement PROD.<br/>- Consulter l'historique et les logs temps réel des jobs. | **Gouvernance de Pipeline :**<br/>Simuler un refus d'approbation manuelle pour prouver l'interruption immédiate de la chaîne de déploiement en production. |

---

## 3. Standard Universel d'un Lab d'Autoformation (80% Pratique)

Chaque fichier `lab.md` du dossier `courses/` doit adopter la structure type suivante :

1. **Mission Métier & User Story** : Pourquoi l'entreprise a besoin de ce composant.
2. **Pre-flight Diagnostic** : Script PowerShell/Bash non-destructif vérifiant que la session est prête.
3. **Micro-Steps HCL Atomiques** : Une seule action par étape, code HCL complet, justification de chaque attribut, et sortie console attendue dans un bloc déroulant.
4. **Vérification Hybride (Double Preuve)** :
   - *Preuve CLI* : Commande `snow sql` ou `az`.
   - *Preuve Web UI* : Navigation pas à pas dans Snowsight, Azure Portal ou Azure DevOps pour "voir" l'objet de ses propres yeux.
5. **Chaos Lab (Panne & Diagnostic)** : Modification manuelle via la console web -> Détection par `terraform plan` -> Correction par ré-alignement.
6. **Auto-Évaluation Automatisée** : `.\scripts\SelfPacedLab.ps1 -Module XX -All -Report`.
7. **Mini-Challenge Non Guidé** : Travail en autonomie sans solution apparente, noté sur 100 points.
8. **Teardown FinOps** : Procédure de nettoyage explicite avec vérification zéro résidu.

---

## 4. Analyse Détaillée & Recommandations Module par Module (M00 à M14)

---

### JOUR 0 — PRÉPARATION & TOOLCHAIN

#### Jour 0 : M00 — Setup & Audit d'Environnement
* **Fichiers actuels :** [`courses/day-00/module-00-setup/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-00/module-00-setup)
* **Diagnostic & Lacunes :** L'apprenant exécute un gros script monolithique. S'il y a un échec sur Azure CLI ou Snowflake CLI, il ne sait pas quelle étape a échoué.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Architecture de l'environnement de formation, convention de nommage `<PREFIXE>_<ZONE>_<ENV>` et gestion des credentials sans mot de passe commité.
  - **Atelier Découpé (40 min) :**
    - *Étape 0.1* : Vérification des outils locaux (`git`, `terraform = 1.14.5`, `snow`, `az`).
    - *Étape 0.2* : Configuration du fichier `.env` à partir de `.env.example` et vérification de son exclusion Git (`git check-ignore .env`).
    - *Étape 0.3* : Connexion Azure CLI (`az login`) et validation de la souscription cible.
    - *Étape 0.4* : Authentification Snowflake CLI (`snow connection test -c training`).
    - *Étape 0.5* : Extraction sécurisée du PAT temporaire depuis Azure Key Vault :
      ```powershell
      az keyvault secret show --vault-name "<KEYVAULT_NAME>" --name "SnowflakePAT-APP01" --query "value" -o tsv
      ```
  - **Vérification Console Web :** L'apprenant se connecte pour la première fois à **Snowflake Snowsight** (`https://app.snowflake.com`) avec son login/mot de passe apprenant, active son profil et confirme l'accès au rôle `SYSADMIN`.
  - **Chaos Lab :** Renseigner un préfixe avec des caractères interdits (ex: `app-01!` au lieu de `APP01`), lancer le preflight, constater le blocage par regex et corriger.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 0 -All` (5 checks : Git, Terraform, Snow CLI, Azure CLI, `.env`).

---

### JOUR 1 — FONDATIONS IAC, STATE & VARIABLES

#### Jour 1 : M01 — Premier Déploiement & Idempotence
* **Fichiers actuels :** [`courses/day-01/module-01-iac-workflow/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-01/module-01-iac-workflow)
* **Diagnostic & Lacunes :** Lab très bien conçu mais demande d'écrire trop de fichiers en un bloc.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Le cycle de vie Terraform (`init -> validate -> plan -> apply`), le rôle du provider et la notion d'idempotence.
  - **Atelier Découpé (60 min) :**
    - *Étape 1.1* : Rédaction de `versions.tf` (épinglage strict Terraform `= 1.14.5` et provider Snowflake `= 2.14.0`).
    - *Étape 1.2* : Rédaction de `provider.tf` exploitant le token PAT lu depuis `secrets/snowflake_pat.txt`.
    - *Étape 1.3* : Création de `snowflake_database.raw` dans `main.tf` et premier `terraform apply`.
    - *Étape 1.4* : Ajout de `snowflake_schema.ingestion` avec dépendance implicite sur la database.
    - *Étape 1.5* : Ajout de `snowflake_warehouse.etl` configuré en `X-SMALL`, `auto_suspend = 60`, `initially_suspended = true`.
  - **Vérification Hybride :**
    - *En CLI* : `snow sql -q "SHOW WAREHOUSES LIKE 'APP01_%';" -c training`.
    - *Dans Snowsight Web UI* : Ouvrir la section *Admin > Warehouses*, constater la présence du warehouse `APP01_ETL_DEV`, son statut "Suspended" (FinOps compliant) et sa taille X-Small.
  - **Chaos Lab (Drift Manuelle via Snowsight) :**
    1. Dans Snowsight, cliquer sur le warehouse `APP01_ETL_DEV` > *Edit* > Passer la taille à `Small`.
    2. Dans le terminal, lancer `terraform plan`.
    3. Observer le diff : `~ warehouse_size = "SMALL" -> "XSMALL"`.
    4. Relancer `terraform apply` pour restaurer la vérité du code.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 1 -All` (contrôle HCL, plan binaire, 3 ressources, idempotence).

---

#### Jour 1 : M02 — State Distant Azure Blob Storage & Verrouillage
* **Fichiers actuels :** [`courses/day-01/module-02-state-management/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-01/module-02-state-management)
* **Diagnostic & Lacunes :** L'explication du verrouillage est abstraite si l'étudiant ne voit pas le bail Azure.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Risques du state local (perte de state, concurrence destructrice, exposition de secrets) et mécanisme de bail (*Blob Lease Lock*) sur Azure Storage.
  - **Atelier Découpé (70 min) :**
    - *Étape 2.1* : Inspection du state local avec `terraform state list` et `terraform state show`.
    - *Étape 2.2* : Vérification du conteneur Azure Blob via Azure CLI :
      ```powershell
      az storage container show --name "tfstate" --account-name "<STORAGE_ACCOUNT>" --auth-mode login
      ```
    - *Étape 2.3* : Création de `backend.tf` déclarant le bloc `backend "azurerm"`.
    - *Étape 2.4* : Migration du state : `terraform init -migrate-state` avec confirmation `yes`.
    - *Étape 2.5* : Vérification de la suppression automatique du fichier local `terraform.tfstate`.
  - **Vérification Hybride :**
    - *Dans le Portail Azure Web (`portal.azure.com`)* : Naviguer dans *Comptes de stockage > Conteneurs > tfstate > APP01/*, observer le fichier `m02.terraform.tfstate`, son horodatage et ses propriétés de chiffrement.
  - **Chaos Lab (State Lock Concurrency) :**
    1. Ouvrir deux fenêtres de terminal côte à côte.
    2. Dans le terminal 1, lancer une commande qui retient le verrou (ou simuler un lock actif).
    3. Dans le terminal 2, lancer immédiatement `terraform plan`.
    4. Observer l'erreur explicite : `Error acquiring the state lock: blob is already leased`.
    5. Apprendre à inspecter le bail sur Azure Portal et comprendre la commande d'urgence `terraform force-unlock`.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 2 -All` (contrôle backend azurerm, migration, state distant).

---

#### Jour 1 : M03 — Brownfield Import & Alignement de Dérive
* **Fichiers actuels :** [`courses/day-01/module-03-import-brownfield/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-01/module-03-import-brownfield)
* **Diagnostic & Lacunes :** Module axé sur l'ancienne commande CLI au lieu de la syntaxe déclarative `import {}` de Terraform 1.5+.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Gestion des ressources existantes hors Terraform et fonctionnement des blocs déclaratifs `import {}` et de `-generate-config-out`.
  - **Atelier Découpé (60 min) :**
    - *Étape 3.1 (Création manuelle via Snowsight)* : Se connecter à **Snowflake Snowsight**, ouvrir une SQL Worksheet et créer manuellement un schema non managé :
      ```sql
      CREATE SCHEMA APP01_RAW_DEV.LEGACY_STAGING COMMENT = 'Created manually by DBA';
      ```
    - *Étape 3.2* : Rédaction du bloc déclaratif dans `import.tf` :
      ```hcl
      import {
        to = snowflake_schema.legacy_staging
        id = "APP01_RAW_DEV.LEGACY_STAGING"
      }
      ```
    - *Étape 3.3* : Génération du code HCL : `terraform plan -generate-config-out=generated.tf`.
    - *Étape 3.4* : Revue critique du fichier `generated.tf`, nettoyage des attributs par défaut et fusion dans `main.tf`.
    - *Étape 3.5* : Application du plan d'alignement avec confirmation de 0 destruction : `Plan: 1 to import, 0 to add, 0 to change, 0 to destroy`.
  - **Chaos Lab :** Modifier la casse de l'identifiant (ex: `app01_raw_dev.legacy_staging` en minuscules), lancer le plan, observer l'erreur d'incohérence Snowflake (sensibilité à la casse des identifiants non quotés) et corriger.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 3 -All` (import réussi, ressource managée, zéro dérive).

---

#### Jour 1 : M04 — Variables, Validations FinOps & Outputs
* **Fichiers actuels :** [`courses/day-01/module-04-variables-outputs/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-01/module-04-variables-outputs)
* **Diagnostic & Lacunes :** Les validations personnalisées HCL méritent d'être appliquées à des règles de gouvernance d'entreprise concrètes.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Typage structurel (`object`, `map`), règles de validation avec messages d'erreur explicites, et masque des secrets dans les outputs (`sensitive = true`).
  - **Atelier Découpé (50 min) :**
    - *Étape 4.1* : Déclaration de variables avec types stricts dans `variables.tf`.
    - *Étape 4.2* : Création d'une règle de validation FinOps bloquante sur la taille de warehouse :
      ```hcl
      variable "warehouse_size" {
        type    = string
        default = "XSMALL"
        validation {
          condition     = contains(["XSMALL", "SMALL"], var.warehouse_size)
          error_message = "Politique FinOps: Seules les tailles XSMALL et SMALL sont admises."
        }
      }
      ```
    - *Étape 4.3* : Création d'une validation regex sur l'environnement (`DEV`, `UAT`, `PROD`).
    - *Étape 4.4* : Utilisation des `locals.tf` pour construire des noms uniformes (`${var.learner_prefix}_${var.zone}_${var.environment}`).
    - *Étape 4.5* : Déclaration d'outputs typés dans `outputs.tf`.
  - **Chaos Lab :** Tenter de forcer une taille `MEDIUM` via CLI (`terraform plan -var="warehouse_size=MEDIUM"`), observer l'arrêt net dès la validation sans aucun appel réseau vers Snowflake.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 4 -All`.

---

### JOUR 2 — INDUSTRIALISATION, MODULES & CI/CD AZURE

#### Jour 2 : M05 — Modules Réutilisables & Landing Zone
* **Fichiers actuels :** [`courses/day-02/module-05-modules/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-02/module-05-modules)
* **Diagnostic & Lacunes :** La séparation physique des dossiers module et le contrat d'appel (*Call Signature*) doivent être clairement matérialisés.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Pattern Landing Zone, principe d'encapsulation HCL, et séparation stricte entre configuration racine (*Root*) et modules enfants (*Child Modules*).
  - **Atelier Découpé (75 min) :**
    - *Étape 5.1* : Création du sous-dossier `modules/landing-zone/`.
    - *Étape 5.2* : Déplacement des ressources Database, Schemas, Warehouses dans le module.
    - *Étape 5.3* : Exposition sélective des informations utiles via `modules/landing-zone/outputs.tf`.
    - *Étape 5.4* : Appel du module dans la racine `main.tf` via le bloc `module "landing_zone" {}`.
    - *Étape 5.5* : Exécution de `terraform init` pour compiler le graphe de modules locaux.
  - **Vérification Hybride :**
    - *En CLI* : `terraform state list` (constater que les adresses sont désormais préfixées par `module.landing_zone...`).
    - *Dans Snowsight Web UI* : Constater que les objets existent toujours et n'ont subi aucune recréation destructive lors du refactoring de code.
  - **Chaos Lab :** Modifier le nom d'un output dans le module sans mettre à jour l'appelant dans le root, lancer `terraform validate`, décrypter le message d'erreur et rétablir le contrat.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 5 -All`.

---

#### Jour 2 : M06 — Logique Dynamique & Meta-Arguments (`for_each`)
* **Fichiers actuels :** [`courses/day-02/module-06-dynamic-logic/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-02/module-06-dynamic-logic)
* **Diagnostic & Lacunes :** Les expressions HCL complexes demandent des exemples graduels pour éviter l'incompréhension de `each.value`.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Pourquoi `count` est dangereux sur des ressources d'état (décalage d'index lors d'une suppression) et comment `for_each` garantit l'immutabilité des identifiants Terraform.
  - **Atelier Découpé (60 min) :**
    - *Étape 6.1* : Définition d'une variable `map(object)` représentant 3 couches de données (`RAW`, `CLEAN`, `CURATED`).
    - *Étape 6.2* : Déploiement de schemas avec `for_each = var.layers` et exploitation de `each.key` et `each.value.comment`.
    - *Étape 6.3* : Application d'expressions ternaires pour faire varier la durée de rétention Time-Travel selon l'environnement :
      ```hcl
      data_retention_time_in_days = var.environment == "PROD" ? 30 : 1
      ```
    - *Étape 6.4* : Mise en œuvre de blocs imbriqués `dynamic "tag" {}`.
  - **Vérification Snowsight Web UI :** Ouvrir la database dans Snowsight, vérifier que les 3 schemas `RAW`, `CLEAN`, `CURATED` apparaissent bien avec leurs commentaires respectifs.
  - **Chaos Lab :** Retirer la couche `CLEAN` du milieu de la map dans `terraform.tfvars`, lancer `terraform plan` et constater que Terraform prévoit exactement 1 destruction ciblée (`module.landing_zone.snowflake_schema.layers["CLEAN"]`) sans recréer `CURATED`.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 6 -All`.

---

#### Jour 2 : M07 — Pipeline CI/CD Azure DevOps
* **Fichiers actuels :** [`courses/day-02/module-07-cicd-pipeline/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-02/module-07-cicd-pipeline)
* **Diagnostic & Lacunes :** Le rôle de l'interface Azure DevOps Web (création de PR, consultation du plan, approbation de gate) doit être le cœur de l'atelier.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Cycle de vie GitOps : branche de fonctionnalité, Pull Request, validation spéculative, approbation humaine et apply automatique sur merge.
  - **Atelier Découpé (80 min) :**
    - *Étape 7.1* : Examen du pipeline YAML `azure-pipelines.yml` et configuration du pool d'agents auto-hébergés.
    - *Étape 7.2* : Création d'une branche Git `feature/add-analytics-wh` en local et push vers le dépôt Azure DevOps Repos.
    - *Étape 7.3 (Console Web Azure DevOps)* : Ouvrir **Azure DevOps Web** (`dev.azure.com`), créer la Pull Request vers `main`.
    - *Étape 7.4 (Console Web Azure DevOps)* : Observer le déclenchement automatique du stage `Validate & Plan` et consulter le rapport de plan publié dans les logs de la PR.
    - *Étape 7.5 (Console Web Azure DevOps)* : Compléter le merge de la PR, observer le déclenchement du stage `Deploy PROD`, **agir en tant qu'approbateur sur l'Approval Gate** et valider le déploiement.
  - **Vérification Snowsight Web UI :** Vérifier dans Snowsight que le warehouse créé via la PR Azure DevOps est instantanément disponible.
  - **Chaos Lab :** Créer une PR contenant une erreur de syntaxe HCL, observer le pipeline Azure DevOps échouer et bloquer le merge de la PR.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 7 -All`.

---

#### Jour 2 : M08 — Stratégie Multi-Environnements (DEV / UAT / PROD)
* **Fichiers actuels :** [`courses/day-02/module-08-environments/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-02/module-08-environments)
* **Diagnostic & Lacunes :** L'isolation des states doit être prouvée visuellement dans le stockage Azure.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Comparatif d'architecture : Workspaces Terraform vs Arborescence par répertoires dédiés (*Directory-Based Layout*), et pourquoi les répertoires dédiés sont la norme de sécurité en entreprise.
  - **Atelier Découpé (60 min) :**
    - *Étape 8.1* : Structuration des dossiers `environments/dev/` et `environments/prod/`.
    - *Étape 8.2* : Déclaration de clés de state distinctes dans `backend.tf` (`dev.terraform.tfstate` vs `prod.terraform.tfstate`).
    - *Étape 8.3* : Instanciation du module Landing Zone dans chaque environnement avec des variables différenciées (Warehouses plus puissants en PROD, auto-suspend plus agressif en DEV).
    - *Étape 8.4* : Déploiement successif de DEV puis de PROD.
  - **Vérification Hybride :**
    - *Dans le Portail Azure Web* : Vérifier la présence des deux fichiers `.tfstate` distincts dans le conteneur Azure Blob.
    - *Dans Snowsight Web UI* : Constater que les objets `_DEV` et `_PROD` coexistent avec leurs configurations respectives.
  - **Chaos Lab :** Modifier la configuration DEV et prouver par `terraform plan` dans le dossier PROD qu'aucune dérive n'affecte l'environnement de production.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 8 -All`.

---

### JOUR 3 — SÉCURITÉ, SECRETS & INGESTION AZURE

#### Jour 3 : M09 — Ingestion ADLS Gen2 & External Stages
* **Fichiers actuels :** [`courses/day-03/module-09-snowflake-advanced/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-03/module-09-snowflake-advanced)
* **Diagnostic & Lacunes :** L'interaction entre Azure Entra ID et Snowflake nécessite d'être vécue pas à pas pour être assimilée.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Le pattern sécurisé `Storage Integration` : délégation d'identité par Principal de Service Microsoft Entra ID sans échange de clés de compte de stockage partagées (*Zero Shared Secrets*).
  - **Atelier Découpé (70 min) :**
    - *Étape 9.1* : Déclaration Terraform de `snowflake_storage_integration` pointant sur Azure Data Lake Gen2.
    - *Étape 9.2* : Définition du format de fichier Parquet via `snowflake_file_format`.
    - *Étape 9.3* : Création du `snowflake_stage` externe lié à l'intégration.
    - *Étape 9.4* : Déploiement via Terraform.
    - *Étape 9.5 (Console Web Azure Portal)* : Naviguer dans le Portail Azure sur le compte ADLS Gen2, vérifier le conteneur de données et uploader un fichier Parquet d'exemple.
    - *Étape 9.6 (Snowsight Web UI)* : Ouvrir une worksheet SQL dans Snowsight et exécuter :
      ```sql
      LIST @APP01_RAW_DEV.INGESTION.AZURE_STAGE;
      COPY INTO APP01_RAW_DEV.INGESTION.CUSTOMER_RAW FROM @AZURE_STAGE;
      SELECT * FROM APP01_RAW_DEV.INGESTION.CUSTOMER_RAW LIMIT 10;
      ```
  - **Chaos Lab :** Révoquer temporairement le rôle RBAC Azure du Principal de Service Snowflake sur le conteneur Azure, tenter un `LIST @stage`, observer l'erreur 403 Forbidden et restaurer l'accès.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 9 -All`.

---

#### Jour 3 : M10 — Identité Technique, Clés RSA & Azure Key Vault
* **Fichiers actuels :** [`courses/day-03/module-10-security-auth/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-03/module-10-security-auth)
* **Diagnostic & Lacunes :** Les étudiants ont du mal à comprendre où se trouve la clé privée par rapport à la clé publique.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Cryptographie asymétrique RSA 2048, authentification par jeton JWT signé, et cycle de vie des secrets d'entreprise dans Azure Key Vault.
  - **Atelier Découpé (75 min) :**
    - *Étape 10.1* : Génération locale d'une paire de clés RSA 2048 chiffrée PKCS#8.
    - *Étape 10.2* : Dépôt sécurisé de la clé privée dans **Azure Key Vault** via Azure CLI :
      ```powershell
      az keyvault secret set --vault-name "<KEYVAULT_NAME>" --name "APP01-RSA-PRIVATE-KEY" --file "rsa_key.p8"
      ```
    - *Étape 10.3* : Création de l'utilisateur technique Snowflake via la ressource `snowflake_user` configurée avec l'attribut `rsa_public_key`.
    - *Étape 10.4* : Configuration du provider Terraform pour s'authentifier avec la clé privée récupérée d'Azure Key Vault au runtime.
    - *Étape 10.5* : **Procédure de Rotation Sans Coupure** : Déclarer la clé secondaire `rsa_public_key_2` dans Terraform, basculer la connexion du script, puis révoquer la clé primaire.
  - **Vérification Hybride :**
    - *Dans le Portail Azure Web* : Consulter le secret dans Azure Key Vault, vérifier ses versions et métadonnées.
    - *Dans Snowsight Web UI* : Exécuter `DESCRIBE USER APP01_SVC_USER;` et constater la présence de l'empreinte digitale de la clé publique RSA.
  - **Chaos Lab :** Tenter une connexion avec une mauvaise clé privée, analyser le message d'erreur Snowflake (`JWT token is invalid`) et auditer les logs d'authentification dans la console.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 10 -All`.

---

### JOUR 4 — GOUVERNANCE, RBAC, FINOPS & CAPSTONE

#### Jour 4 : M11 — RBAC as Code & Sécurité au Moindre Privilège
* **Fichiers actuels :** [`courses/day-04/module-11-rbac/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-04/module-11-rbac)
* **Diagnostic & Lacunes :** L'héritage des privilèges doit être testé par des utilisateurs réels pour être compris.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Modèle RBAC d'entreprise : Rôles d'Accès (*Access Roles* `AR_*`) versus Rôles Fonctionnels (*Functional Roles* `FR_*`), et pourquoi les Future Grants sont indispensables en production.
  - **Atelier Découpé (80 min) :**
    - *Étape 11.1* : Déclaration des rôles d'accès `AR_RAW_READ` et `AR_RAW_WRITE` via `snowflake_account_role`.
    - *Étape 11.2* : Attribution des privilèges sur bases et schemas via `snowflake_grant_privileges_to_account_role`.
    - *Étape 11.3* : Définition des **Future Grants** pour automatiser les droits sur toute nouvelle table créée.
    - *Étape 11.4* : Création du rôle fonctionnel `FR_DATA_ANALYST` et attribution de `AR_RAW_READ`.
    - *Étape 11.5* : Déploiement du RBAC via Terraform.
  - **Vérification & Test dans Snowsight Web UI :**
    1. Dans Snowsight, changer de rôle actif en haut à droite : basculer sur `FR_DATA_ANALYST`.
    2. Ouvrir une worksheet et tester la lecture : `SELECT * FROM ...;` -> **Succès**.
    3. Tester une écriture interdite : `DROP TABLE ...;` ou `DELETE FROM ...;` -> **Échec 403 (Privilege insufficient)**.
  - **Chaos Lab :** Omettre le privilège `USAGE` sur la database parente dans le code Terraform, observer que le rôle ne voit même plus les schemas malgré ses droits sur les tables (rupture de la chaîne d'héritage), et corriger.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 11 -All`.

---

#### Jour 4 : M12 — Projet Fil Rouge (Enterprise Capstone)
* **Fichiers actuels :** [`courses/day-04/module-12-capstone/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-04/module-12-capstone)
* **Diagnostic & Lacunes :** Le projet doit donner à l'apprenant un véritable cahier des charges d'architecture sans lui révéler le code à l'avance.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Les 5 Piliers du *Well-Architected Framework* (Sécurité, Fiabilité, Efficacité, FinOps, Excellence Opérationnelle) et critères d'audit d'une plateforme composée.
  - **Atelier Découpé (120 min - Autonomie Guidée) :**
    - L'apprenant reçoit le cahier des charges officiel d'entreprise :
      1. Assembler le module Landing Zone pour déployer les zones `RAW` et `ANALYTICS`.
      2. Configurer le backend d'état distant sur Azure Blob Storage.
      3. Déployer la matrice RBAC complète avec Future Grants.
      4. Associer un Resource Monitor pour capper les coûts.
      5. Configurer et exécuter le pipeline Azure DevOps complet pour valider la promotion en PROD.
  - **Vérification Complète :**
    - *Sur Azure Portal* : State Blob et Key Vault audités.
    - *Sur Azure DevOps* : Pipeline vert avec approbation confirmée.
    - *Sur Snowsight* : Plateforme complète navigable à la souris.
  - **Audit Automatisé :** Le script teste la conformité du code, l'absence de secrets, et l'idempotence absolue (`0 to add, 0 to change, 0 to destroy`).
  - **Score :** Génération d'une grille d'évaluation notée sur 100 points.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 12 -All -Report`.

---

#### Jour 4 : M13 — FinOps & Observabilité Snowflake dbt
* **Fichiers actuels :** [`courses/day-04/module-13-finops-observability/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-04/module-13-finops-observability)
* **Diagnostic & Lacunes :** Rendre la consommation de crédits concrète et visible dans Snowsight.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Modèle de facturation Snowflake (Crédits Compute, Stockage, Cloud Services) et mise sous tutelle budgétaire par les Resource Monitors.
  - **Atelier Découpé (50 min) :**
    - *Étape 13.1* : Déclaration d'un `snowflake_resource_monitor` avec quota mensuel, alerte à 80% et suspension stricte à 100%.
    - *Étape 13.2* : Rattachement du moniteur aux warehouses de l'apprenant.
    - *Étape 13.3* : Déploiement Terraform.
    - *Étape 13.4* : Exécution d'un modèle dbt simple interrogeant la vue `SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY`.
  - **Vérification Snowsight Web UI :** Naviguer dans *Admin > Cost Management > Resource Monitors*, observer la jauge de consommation de crédits et vérifier les quotas appliqués.
  - **Chaos Lab :** Abaisser artificiellement le quota du moniteur à un seuil inférieur à la consommation courante, tenter de démarrer le warehouse et constater le blocage immédiat imposé par Snowflake.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 13 -All`.

---

#### Jour 4 : M14 — Data Products, Tagging & Masquage Dynamique
* **Fichiers actuels :** [`courses/day-04/module-14-data-products/`](file:///d:/Data2AI%20Academy/Snowflake-terraform/courses/day-04/module-14-data-products)
* **Diagnostic & Lacunes :** Démontrer visuellement comment les tags et les politiques de masquage protègent les données sensibles.
* **Recommandations Pédagogiques (80% Lab) :**
  - **Micro-Théorie (10 min) :** Principes du Data Mesh : Data Product gouverné, métadonnées sémantiques (*Object Tagging*) et protection des données à caractère personnel (RGPD/PII) par masquage dynamique.
  - **Atelier Découpé (50 min) :**
    - *Étape 14.1* : Création de tags de gouvernance via la ressource `snowflake_tag` (`CostCenter`, `DataOwner`, `PII_Level`).
    - *Étape 14.2* : Association automatique des tags aux tables et colonnes via `snowflake_tag_association`.
    - *Étape 14.3* : Déploiement d'une politique de masquage dynamique (*Masking Policy*) masquant les emails (`***@***.com`) pour les utilisateurs sans privilèges spécifiques.
    - *Étape 14.4* : Déploiement Terraform.
  - **Vérification Snowsight Web UI :**
    1. Dans Snowsight, exécuter une requête avec le rôle `SYSADMIN` : les emails apparaissent en clair.
    2. Basculer sur le rôle `FR_DATA_ANALYST` et ré-exécuter la même requête : **les emails sont automatiquement masqués**.
  - **Teardown Final (Nettoyage FinOps Certifié) :** Exécuter `terraform destroy -auto-approve` pour nettoyer l'ensemble des ressources créées et vérifier dans Snowsight et Azure Portal que le compte est vierge de tout résidu facturable.
  - **Auto-Validation :** `SelfPacedLab.ps1 -Module 14 -All`.

---

## 5. Matrice Synthétique des Livrables & Preuves

| Module | Tâche Métier | Preuve CLI | Preuve Console Web | Checkpoint `validate.ps1` |
|---|---|---|---|---|
| **M00** | Setup Toolchain & Connexions | `snow connection test` | Connexion réussie à Snowsight | Checkpoint Toolchain & `.env` |
| **M01** | Premier déploiement IaC | `snow sql "SHOW WAREHOUSES"` | Warehouse visible dans Snowsight | Database, Schema, Warehouse X-Small |
| **M02** | State distant Azure Blob | `az storage blob show` | Fichier `.tfstate` sur Azure Portal | Backend `azurerm` & lock validés |
| **M03** | Brownfield Import | `terraform plan` (0 to add) | Objet legacy managé dans Snowsight | Bloc `import {}` & configuration générée |
| **M04** | Validations FinOps & Outputs | `terraform validate` | Sortie console bloquante | Validations regex et FinOps |
| **M05** | Modules Réutilisables | `terraform state list` | Arborescence intacte dans Snowsight | Contrat d'interface inputs/outputs |
| **M06** | Logique dynamique (`for_each`) | `terraform plan` | 3 schemas visibles dans Snowsight | Itération stable sans décalage |
| **M07** | Pipeline CI/CD Azure DevOps | `git push` | PR & Approval validés sur Azure DevOps | Fichier `azure-pipelines.yml` complet |
| **M08** | Multi-Environnements | `terraform plan` DEV/PROD | Objets `_DEV` et `_PROD` distincts | Clés de state isolées dans Azure |
| **M09** | Ingestion ADLS Gen2 | `COPY INTO` réussi | Fichiers Parquet sur Azure Portal | Storage Integration & Stage externe |
| **M10** | Clés RSA & Azure Key Vault | `az keyvault secret show` | Empreinte publique dans Snowsight | Clé RSA 2048 & zero secret commité |
| **M11** | RBAC as Code | Script SQL de test unitaire | Test positif/négatif dans Snowsight | Matrice de rôles & Future Grants |
| **M12** | Enterprise Capstone | `terraform plan` (Zero-drift) | Plateforme complète navigable | Assemblage Well-Architected (100 pts) |
| **M13** | FinOps & dbt | Requête `ACCOUNT_USAGE` | Jauge de crédits dans Snowsight | Resource Monitor rattaché |
| **M14** | Data Products & Masquage | `terraform destroy` propre | Masquage dynamique dans Snowsight | Tags de gouvernance & Teardown certifié |

---

## 6. Plan d'Application Opérationnel

Voici les actions à déployer pour appliquer immédiatement ces recommandations :

1. **Intégrer les sections de vérification Web dans les 15 `lab.md`** :
   - Ajouter pour chaque atelier le bloc pas-à-pas guidant l'étudiant dans **Snowflake Snowsight**, **Azure Portal** et **Azure DevOps**.
2. **Ajouter les scénarios Chaos Lab Web** :
   - Formaliser dans chaque module l'étape où l'étudiant modifie manuellement un paramètre à la souris dans Snowsight pour voir comment Terraform détecte la dérive au terminal.
3. **Mettre à disposition les validateurs Bash équivalents (`validate.sh`)** :
   - Nous avons généré les 15 fichiers `validate.ps1` ; ajouter les scripts `.sh` pour les étudiants sur macOS / Linux.
4. **Vérifier le runner global** :
   - Tester l'exécution séquentielle via `.\scripts\SelfPacedLab.ps1 -Module X -All -Report`.

---
*Document de référence prêt pour exécution immédiate sur le référentiel.*
