# Catalogue — Formation Terraform & Snowflake

**Parcours officiel : 5 jours × 6 heures — 30 heures**

**Stack :** Snowflake Enterprise, Terraform, Azure, Azure DevOps, dbt

**Références :** [`PROGRAMME_FORMATION.md`](../PROGRAMME_FORMATION.md) · [architecture](../docs/reference-architecture.md) · [versions](../docs/version-policy.md)

## Mode d’emploi

1. Réalisez le préflight et confirmez votre accès Snowflake ainsi que votre préfixe apprenant.
2. Créez un workspace propre pour le module.
3. Suivez le `course.md`, puis le `lab.md` sans consulter la solution.
4. Exécutez les checkpoints Windows ou Unix.
5. Comparez vos preuves à `expected-output.md`.
6. Utilisez `troubleshooting.md` avant de demander ou consulter un indice.
7. Terminez le challenge et le quiz.
8. Exécutez le cleanup indiqué.

> La structure historique `day-00` à `day-04` reste disponible pendant la refonte. Le catalogue cible ci-dessous fait autorité; les modules seront remappés par lots sans suppression implicite des supports existants.

## Légende

| Badge | Portée |
|---|---|
| `[CORE]` | Obligatoire : Terraform, Snowflake, Azure, Azure DevOps |
| `[ANNEXE]` | Comparaison AWS ou GCP, non exécutée |
| `[WINDOWS]`, `[UNIX]` | Commande propre au shell |
| `[CHECK]` | Checkpoint ou preuve |
| `[SECURITY]` | Identité, privilège ou secret |
| `[COST]` | Ressource facturable |
| `[CLEANUP]` | Nettoyage contrôlé |

## Convention de nommage

```text
<PREFIXE_APPRENANT>_<ZONE>_<ENVIRONNEMENT>
```

Exemples : `ABC_RAW_DEV`, `ABC_ETL_UAT`. Les environnements sont **DEV**, **UAT** et **PROD** dans un compte Snowflake unique.

## Jour 1 — Préparer, créer et déployer (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Orientation, sécurité et coûts | 0 h 45 | [Point d’entrée Day 0](day-00/README.md) |
| Préflight Windows/Unix | 1 h 00 | [Installation et vérification](day-00/module-00-tools-setup/lab.md) |
| Accès Snowflake et préfixe apprenant | 1 h 00 | [Lab Day 0 actif](day-00/module-00-day0-setup/lab.md) |
| Premier projet créé depuis zéro | 2 h 15 | M1 refondu |
| Workflow Terraform et preuves | 0 h 45 | M1 refondu |
| Évaluation et cleanup | 0 h 15 | M1 refondu |
| **Total** | **6 h 00** | |

**Livrable :** database, schema et warehouse Snowflake créés par un projet écrit par l’apprenant.

## Jour 2 — State et maîtrise du changement (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| State local et sécurité | 0 h 45 | M2 refondu |
| Backend Azure Blob Storage | 1 h 15 | M2 refondu |
| Variables, locals et conventions | 1 h 00 | M4 refondu |
| Logique dynamique et lifecycle | 1 h 00 | M4/M6 réorganisés |
| Import brownfield et dérive | 1 h 15 | M3 refondu |
| Challenge et idempotence | 0 h 45 | Nouveau challenge J2 |
| **Total** | **6 h 00** | |

**Livrable :** state cohérent, ressource importée sans recréation et dérive corrigée intentionnellement.

## Jour 3 — Modules et environnements (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Contrat de module | 0 h 45 | M5 refondu |
| Landing Zone créée depuis zéro | 2 h 00 | M5 refondu |
| Couches RAW/CLEAN/CURATED | 0 h 45 | M6 refondu |
| Environnements DEV/UAT et promotion PROD | 1 h 15 | M8 refondu |
| Qualité et versioning | 0 h 45 | M5/M8 |
| Challenge d’extension | 0 h 30 | Nouveau challenge J3 |
| **Total** | **6 h 00** | |

**Livrable :** module réutilisable et deux environnements isolés.

## Jour 4 — Sécurité et RBAC Snowflake (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Modèle de privilèges | 0 h 45 | M10/M11 réorganisés |
| RBAC as Code | 1 h 30 | M11 refondu |
| Grants actuels/futurs | 0 h 45 | M11 refondu |
| Identité technique, JWT et Key Vault | 1 h 00 | M10 refondu |
| Ingestion Azure Data Lake Storage | 0 h 45 | M9 refondu |
| Troubleshooting contrôlé | 0 h 45 | M9–M11 |
| Challenge moindre privilège | 0 h 30 | Nouveau challenge J4 |
| **Total** | **6 h 00** | |

**Livrable :** RBAC vérifié par tests positifs/négatifs et identité technique sécurisée.

## Jour 5 — CI/CD, FinOps, Data Products et capstone (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Pipeline Azure DevOps | 1 h 00 | M7 refondu |
| Policy as Code et quality gates | 0 h 30 | M7 refondu |
| FinOps Snowflake/dbt | 0 h 45 | M13 intégré |
| Data Products SALES/FINANCE | 0 h 45 | M14 intégré |
| Capstone challenge | 2 h 15 | M12 refondu |
| Soutenance, zero-drift et cleanup | 0 h 45 | M12 refondu |
| **Total** | **6 h 00** | |

**Livrable :** plateforme composée et évaluée, pipeline de qualité, indicateurs FinOps et Data Products gouvernés.

## Structure standard cible d’un module

```text
module-XX-name/
├── README.md
├── course.md
├── lab.md
├── expected-output.md
├── troubleshooting.md
├── quiz.md
├── starter/
├── solution/
├── validate.ps1
├── validate.sh
└── assets/
```

Le `starter/` ne contient pas le code que l’apprenant doit apprendre à écrire. Il peut contenir des données, validateurs et assets non pédagogiques. La solution est séparée et n’est jamais copiée automatiquement dans le workspace.

## Contrat de validation

| Niveau | Contrôle |
|---|---|
| 1 | Structure et absence de placeholders/secrets |
| 2 | `terraform fmt -check` et `terraform validate` |
| 3 | Assertions sur le plan Terraform |
| 4 | Preuve fonctionnelle Snowflake, Snow CLI ou dbt |
| 5 | Second plan sans changement inattendu |
| 6 | Challenge évalué par critères |

## Code de référence actuel

| Capacité | Code de référence |
|---|---|
| Bootstrap Azure (state) | `project/00-bootstrap` |
| Fondamentaux | `project/01-day1-basics` |
| Backend Azure Blob | `project/02-day1-state` |
| Modules et environnements | `project/03-day2-modules` |
| RBAC | `project/04-day3-rbac` |
| Capstone | `project/05-capstone` |
| Data Products | `project/06-data-products` |
| Agents Azure DevOps | `project/07-devops-agents` |
| Pipeline CI/CD | `azure-pipelines.yml` |
| FinOps | `finops/` |

Ces dossiers deviennent des **solutions testables**. Ils ne constituent plus le workspace principal de l’apprenant.

## Règles de sécurité

- aucun secret dans Git, les captures ou les rapports;
- aucun mot de passe Snowflake dans une racine enseignée;
- aucun `.terraform/`, state ou plan distribué dans un starter;
- ressources préfixées par apprenant et suffixées par environnement;
- warehouse économique avec auto-suspend;
- avertissement et portée avant toute destruction ou policy réseau;
- cleanup vérifié côté Snowflake **et** côté Azure;
- rôle d’administration limité aux opérations qui l’exigent réellement.

## Versions

Les versions des outils et providers sont définies dans la [politique de versions](../docs/version-policy.md). Aucun support ne redéfinit une version localement.
