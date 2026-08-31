# Catalogue — Formation Terraform & Snowflake

**Parcours officiel : 5 jours × 6 heures — 30 heures**  
**Source de vérité :** [`PROGRAMME_FORMATION.md`](../PROGRAMME_FORMATION.md)

## Mode d’emploi

1. Réalisez le préflight et choisissez votre scénario d’accès Snowflake.
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
| `[CORE]` | Obligatoire et cloud-agnostique |
| `[AZURE]`, `[AWS]`, `[GCP]` | Piste Cloud optionnelle |
| `[WINDOWS]`, `[UNIX]` | Commande propre au shell |
| `[CHECK]` | Checkpoint ou preuve |
| `[SECURITY]` | Identité, privilège ou secret |
| `[CLEANUP]` | Nettoyage contrôlé |

## Jour 1 — Préparer, créer et déployer (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Orientation, sécurité et coûts | 0 h 45 | M0 Day 0 |
| Préflight Windows/Unix | 1 h 00 | `day-00/module-00-tools-setup` à fusionner |
| Accès sandbox ou Trial | 1 h 00 | `day-00/module-00-day0-setup` |
| Premier projet créé depuis zéro | 2 h 15 | M1 refondu |
| Workflow Terraform et preuves | 0 h 45 | M1 refondu |
| Évaluation et cleanup | 0 h 15 | M1 refondu |
| **Total** | **6 h 00** | |

**Livrable :** database, schema et warehouse Snowflake créés par un projet écrit par l’apprenant.

## Jour 2 — State et maîtrise du changement (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| State local et sécurité | 0 h 45 | M2 refondu |
| Variables, locals et conventions | 1 h 00 | M4 refondu |
| Logique dynamique et lifecycle | 1 h 00 | M4/M6 réorganisés |
| Import brownfield et refactoring | 1 h 15 | M3 refondu |
| Drift et remédiation | 0 h 45 | M1/M3 réorganisés |
| Backend distant + pistes Cloud | 0 h 45 | M2 découplé d’Azure |
| Challenge et idempotence | 0 h 30 | Nouveau challenge J2 |
| **Total** | **6 h 00** | |

**Livrable :** state cohérent, ressource importée sans recréation et dérive corrigée intentionnellement.

## Jour 3 — Modules et environnements (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Contrat de module | 0 h 45 | M5 refondu |
| Landing Zone créée depuis zéro | 2 h 00 | M5 refondu |
| Collections RAW/SILVER/GOLD | 0 h 45 | M6 refondu |
| Environnements DEV/TEST | 1 h 00 | M8 refondu |
| Qualité et versioning | 0 h 45 | M5/M8 |
| Challenge d’extension | 0 h 45 | Nouveau challenge J3 |
| **Total** | **6 h 00** | |

**Livrable :** module réutilisable et deux environnements isolés.

## Jour 4 — Sécurité et RBAC Snowflake (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Modèle de privilèges | 0 h 45 | M10/M11 réorganisés |
| RBAC as Code | 1 h 30 | M11 refondu |
| Grants actuels/futurs | 1 h 00 | M11 refondu |
| PAT, JWT et rotation | 0 h 45 | M10 refondu |
| File format et internal stage | 0 h 45 | M9 cloud-agnostique |
| Troubleshooting contrôlé | 0 h 45 | M9–M11 |
| Challenge moindre privilège | 0 h 30 | Nouveau challenge J4 |
| **Total** | **6 h 00** | |

**Livrable :** RBAC vérifié par tests positifs/négatifs et identité technique sécurisée.

## Jour 5 — CI/CD, FinOps, Data Products et capstone (6 h)

| Séquence | Durée | Support actuel / cible |
|---|---:|---|
| Pipeline portable | 0 h 45 | M7 refondu |
| GitHub Actions + mapping Azure DevOps | 0 h 45 | M7 refondu |
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
| Bootstrap historique Azure | `project/00-bootstrap` |
| Fondamentaux | `project/01-day1-basics` |
| State historique Azure | `project/02-day1-state` |
| Modules et environnements | `project/03-day2-modules` |
| RBAC | `project/04-day3-rbac` |
| Capstone | `project/05-capstone` |
| Data Products | `project/06-data-products` |
| FinOps | `finops/` |

Ces dossiers deviennent des **solutions testables**. Ils ne constituent plus le workspace principal de l’apprenant.

## Règles de sécurité

- aucun secret dans Git, les captures ou les rapports;
- aucun `.terraform/`, state ou plan distribué dans un starter;
- ressources préfixées par apprenant;
- warehouse économique avec auto-suspend;
- avertissement et portée avant toute destruction ou policy réseau;
- cleanup vérifié;
- `ACCOUNTADMIN` limité au bootstrap qui l’exige.
