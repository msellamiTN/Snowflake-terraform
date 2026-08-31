# Résultat attendu — M0 : environnement

Les numéros de version exacts peuvent évoluer selon la politique de versions. Les commandes doivent se terminer avec succès.

## Préflight local

```text
[PASS] Git
[PASS] Terraform
[PASS] Snowflake CLI
[PASS] .env.example
[PASS] .gitignore
[PASS] .env local
[PASS] Configuration complétée
[PASS] .env ignoré par Git
[PASS] secrets/ ignoré par Git
```

VS Code peut apparaître en `WARN` si un autre éditeur est utilisé.

## Connexion Snowflake

```text
Connection status: OK
```

La requête de preuve affiche l’utilisateur, le rôle et le compte attendus pour la sandbox ou le Trial. Elle n’affiche pas le PAT.

## Workspace

```text
$HOME/Data2AI-Labs/
└── module-00-environment/
    ├── .git/
    ├── .gitignore
    ├── .student-workspace.json
    └── README.md
```

Le dépôt Git du workspace est distinct du dépôt de formation.

## Validation finale

```text
[PASS] Workspace metadata
[PASS] Git
[PASS] Terraform
[PASS] Snowflake CLI
[PASS] .env local
[PASS] .env ignored
[PASS] Secrets ignored
[PASS] No unresolved identifiers
[PASS] Snowflake connection
Result: 9/9
Ready for Day 1
```

Le nombre de contrôles peut être 8 si aucun contrôle conditionnel supplémentaire n’est activé. Le critère déterminant est l’absence de `FAIL` et la ligne `Ready for Day 1`.
