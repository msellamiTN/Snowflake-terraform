# Catalogue — Formation Terraform & Snowflake

**Parcours officiel : 5 jours x 6 heures — 30 heures**

**Stack :** Snowflake Enterprise, Terraform, Azure, Azure DevOps, dbt

**References :** [`PROGRAMME_FORMATION.md`](../PROGRAMME_FORMATION.md) · [architecture](../docs/reference-architecture.md) · [versions](../docs/version-policy.md)

## Mode d'emploi

1. Realisez le preflight et confirmez votre acces Snowflake ainsi que votre prefixe apprenant.
2. Creez un workspace propre pour le module.
3. Suivez le `course.md`, puis le `lab.md` sans consulter la solution.
4. Executez les checkpoints Windows ou Unix.
5. Comparez vos preuves a `expected-output.md`.
6. Utilisez `troubleshooting.md` avant de demander ou consulter un indice.
7. Terminez le challenge et le quiz.
8. Executez le cleanup indique.

## Legend

| Badge | Portee |
|---|---|
| `[CORE]` | Obligatoire : Terraform, Snowflake, Azure, Azure DevOps |
| `[ANNEXE]` | Comparaison AWS ou GCP, non executee |
| `[WINDOWS]`, `[UNIX]` | Commande propre au shell |
| `[CHECK]` | Checkpoint ou preuve |
| `[SECURITY]` | Identite, privilege ou secret |
| `[COST]` | Ressource facturable |
| `[CLEANUP]` | Nettoyage controle |

## Convention de nommage

```text
<PREFIXE_APPRENANT>_<ZONE>_<ENVIRONNEMENT>
```

Exemples : `ABC_RAW_DEV`, `ABC_ETL_UAT`. Les environnements sont **DEV**, **UAT** et **PROD** dans un compte Snowflake unique.

---

## Jour 0 — Preparer votre environnement (1 h 30)

> [Point d'entree Day 0 ->](day-00/README.md)

Le Jour 0 est **automatise** : clonez le projet type, executez les scripts, configurez les connexions Snowflake et Azure. Aucune ressource Cloud n'est creee.

| Etape | Duree | Support |
|---|---:|---|
| Installation et verification des outils | 40 min | [Lab Jour 0](day-00/module-00-setup/lab.md) |
| Connexion Snowflake + Azure + validation | 50 min | [Lab Jour 0](day-00/module-00-setup/lab.md) |
| **Total** | **1 h 30** | |

**Livrable :** `Toolchain status: READY` + `snow sql -q 'SELECT 1' -c training` + `Test-LabConnectivity -> READY`

---

## Jour 1 — Fondations, State, Import (6 h)

> [Point d'entree Day 1 ->](day-01/README.md)

| Module | Duree | Lab | Course | Troubleshooting |
|---|---:|---|---|---|
| M1 — IaC Workflow | 1h30 | [lab](day-01/module-01-iac-workflow/lab.md) | [cours](day-01/module-01-iac-workflow/course.md) | [guide](day-01/module-01-iac-workflow/troubleshooting.md) |
| M2 — State Management | 2h | [lab](day-01/module-02-state-management/lab.md) | [cours](day-01/module-02-state-management/course.md) | [guide](day-01/module-02-state-management/troubleshooting.md) |
| M3 — Import Brownfield | 2h | [lab](day-01/module-03-import-brownfield/lab.md) | [cours](day-01/module-03-import-brownfield/course.md) | [guide](day-01/module-03-import-brownfield/troubleshooting.md) |
| M4 — Variables & Outputs | 1h30 | [lab](day-01/module-04-variables-outputs/lab.md) | [cours](day-01/module-04-variables-outputs/course.md) | [guide](day-01/module-04-variables-outputs/troubleshooting.md) |

**Livrable :** database, schema et warehouse Snowflake crees par un projet ecrit par l'apprenant.

---

## Jour 2 — Modules, CI/CD, Environnements (6 h)

> [Point d'entree Day 2 ->](day-02/README.md)

| Module | Duree | Lab | Course | Troubleshooting |
|---|---:|---|---|---|
| M5 — Modules reutilisables | 2h | [lab](day-02/module-05-modules/lab.md) | [cours](day-02/module-05-modules/course.md) | [guide](day-02/module-05-modules/troubleshooting.md) |
| M6 — Logique dynamique | 1h30 | [lab](day-02/module-06-dynamic-logic/lab.md) | [cours](day-02/module-06-dynamic-logic/course.md) | [guide](day-02/module-06-dynamic-logic/troubleshooting.md) |
| M7 — CI/CD Pipeline | 2h | [lab](day-02/module-07-cicd-pipeline/lab.md) | [cours](day-02/module-07-cicd-pipeline/course.md) | [guide](day-02/module-07-cicd-pipeline/troubleshooting.md) |
| M8 — Environnements | 1h30 | [lab](day-02/module-08-environments/lab.md) | [cours](day-02/module-08-environments/course.md) | [guide](day-02/module-08-environments/troubleshooting.md) |

**Livrable :** module reutilisable et deux environnements isoles.

---

## Jour 3 — Securite et RBAC Snowflake (6 h)

> [Point d'entree Day 3 ->](day-03/README.md)

| Module | Duree | Lab | Course | Troubleshooting |
|---|---:|---|---|---|
| M9 — Ingestion et ressources avancees | 0h45 | [lab](day-03/module-09-snowflake-advanced/lab.md) | [cours](day-03/module-09-snowflake-advanced/course.md) | [guide](day-03/module-09-snowflake-advanced/troubleshooting.md) |
| M10 — Identite technique et Key Vault | 1h00 | [lab](day-03/module-10-security-auth/lab.md) | [cours](day-03/module-10-security-auth/course.md) | [guide](day-03/module-10-security-auth/troubleshooting.md) |

**Livrable :** RBAC verifie par tests positifs/negatifs et identite technique securisee.

---

## Jour 4 — Capstone, FinOps, Data Products (6 h)

> [Point d'entree Day 4 ->](day-04/README.md)

| Module | Duree | Lab | Course | Troubleshooting |
|---|---:|---|---|---|
| M11 — RBAC as Code | 2h15 | [lab](day-04/module-11-rbac/lab.md) | [cours](day-04/module-11-rbac/course.md) | [guide](day-04/module-11-rbac/troubleshooting.md) |
| M12 — Capstone | 2h15 | [lab](day-04/module-12-capstone/lab.md) | [cours](day-04/module-12-capstone/course.md) | [guide](day-04/module-12-capstone/troubleshooting.md) |
| M13 — FinOps & Observabilite | 0h45 | [lab](day-04/module-13-finops-observability/lab.md) | [cours](day-04/module-13-finops-observability/course.md) | [guide](day-04/module-13-finops-observability/troubleshooting.md) |
| M14 — Data Products | 0h45 | [lab](day-04/module-14-data-products/lab.md) | [cours](day-04/module-14-data-products/course.md) | [guide](day-04/module-14-data-products/troubleshooting.md) |

**Livrable :** plateforme composee et evaluee, pipeline de qualite, indicateurs FinOps et Data Products gouvernes.

---

## Structure standard d'un module

```text
module-XX-name/
├── course.md           ← concepts (lire avant le lab)
├── lab.md              ← atelier pratique pas a pas
├── expected-output.md  ← resultats attendus pour comparaison
├── troubleshooting.md  ← diagnostics non destructifs
├── slides.md           ← support de presentation
├── starter/            ← squelette (sans code de ressource)
├── solution/           ← solution de reference (ne pas copier)
└── assets/             ← diagrammes et captures
```

Le `starter/` ne contient pas le code que l'apprenant doit apprendre a ecrire. Il peut contenir des donnees, validateurs et assets non pedagogiques. La solution est separee et n'est jamais copiee automatiquement dans le workspace.

## Navigation rapide

| Jour | Modules | Point d'entree |
|---|---|---|
| Jour 0 | M00 | [day-00/README.md](day-00/README.md) |
| Jour 1 | M1 → M4 | [day-01/README.md](day-01/README.md) |
| Jour 2 | M5 → M8 | [day-02/README.md](day-02/README.md) |
| Jour 3 | M9 → M10 | [day-03/README.md](day-03/README.md) |
| Jour 4 | M11 → M14 | [day-04/README.md](day-04/README.md) |

## Contrat de validation

| Niveau | Controle |
|---|---|
| 1 | Structure et absence de placeholders/secrets |
| 2 | `terraform fmt -check` et `terraform validate` |
| 3 | Assertions sur le plan Terraform |
| 4 | Preuve fonctionnelle Snowflake, Snow CLI ou dbt |
| 5 | Second plan sans changement inattendu |
| 6 | Challenge evalue par criteres |

## Regles de securite

- aucun secret dans Git, les captures ou les rapports;
- aucun mot de passe Snowflake dans une racine enseignee;
- aucun `.terraform/`, state ou plan distribue dans un starter;
- ressources prefixees par apprenant et suffixees par environnement;
- warehouse economique avec auto-suspend;
- avertissement et portee avant toute destruction ou policy reseau;
- cleanup verifie cote Snowflake **et** cote Azure;
- role d'administration limite aux operations qui l'exigent reellement.

## Versions

Les versions des outils et providers sont definies dans la [politique de versions](../docs/version-policy.md). Aucun support ne redefinit une version localement.
