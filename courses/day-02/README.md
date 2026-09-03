# Jour 2 — Modules, CI/CD, Environnements

**Objectif :** Composants reutilisables et deploiement automatise.

> [<- Catalogue](../README.md) · [Jour 1](../day-01/README.md) · **Jour 2** · [Jour 3 ->](../day-03/README.md)

## Progression

```mermaid
flowchart LR
    M5[M5 Modules] --> M6[M6 Dynamic]
    M6 --> M7[M7 CI/CD]
    M7 --> M8[M8 Envs]
    M8 --> J3[Jour 3]
```

## Modules

| Module | Duree | Lab | Course | Troubleshooting | Resultat attendu |
|---|---:|---|---|---|---|
| [M5 — Modules reutilisables](module-05-modules/lab.md) | 2h | [lab](module-05-modules/lab.md) | [cours](module-05-modules/course.md) | [guide](module-05-modules/troubleshooting.md) | [output](module-05-modules/expected-output.md) |
| [M6 — Logique dynamique](module-06-dynamic-logic/lab.md) | 1h30 | [lab](module-06-dynamic-logic/lab.md) | [cours](module-06-dynamic-logic/course.md) | [guide](module-06-dynamic-logic/troubleshooting.md) | [output](module-06-dynamic-logic/expected-output.md) |
| [M7 — CI/CD Pipeline](module-07-cicd-pipeline/lab.md) | 2h | [lab](module-07-cicd-pipeline/lab.md) | [cours](module-07-cicd-pipeline/course.md) | [guide](module-07-cicd-pipeline/troubleshooting.md) | [output](module-07-cicd-pipeline/expected-output.md) |
| [M8 — Environnements](module-08-environments/lab.md) | 1h30 | [lab](module-08-environments/lab.md) | [cours](module-08-environments/course.md) | [guide](module-08-environments/troubleshooting.md) | [output](module-08-environments/expected-output.md) |

## Workflow du jour

1. **Lisez** le `course.md` du module (concepts, 15-20 min)
2. **Realisez** le `lab.md` pas a pas (creation de fichiers, execution, checkpoints)
3. **Comparez** avec `expected-output.md`
4. **Consultez** `troubleshooting.md` en cas d'erreur
5. **Passez** au module suivant

> `[WINDOWS]` Si l'execution de scripts `.ps1` est bloquee, autorisez les scripts locaux :
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

## Livrable du jour

Module reutilisable et deux environnements isoles (DEV/UAT).
Pipeline CI/CD avec quality gates sur Azure DevOps.

## Navigation

[<- Catalogue](../README.md) · [Jour 1](../day-01/README.md) · **Jour 2** · [Jour 3 ->](../day-03/README.md)
