# Jour 2 — Modules, CI/CD, Environnements

**Objectif :** Composants réutilisables et déploiement automatisé.

```mermaid
flowchart LR
    M5[M5 Modules] --> M6[M6 Dynamic]
    M6 --> M7[M7 CI/CD]
    M7 --> M8[M8 Envs]
    M8 --> P[project/03-day2-modules]
```

| Module | Durée | Code |
|--------|-------|------|
| [M5 Modules](module-05-modules/) | 2h | `modules/landing-zone` |
| [M6 Dynamic](module-06-dynamic-logic/) | 1h30 | `schemas.tf` |
| [M7 CI/CD](module-07-cicd-pipeline/) | 2h | `.github/workflows/` |
| [M8 Environments](module-08-environments/) | 1h30 | `environments/dev\|test` |

