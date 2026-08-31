# Solution de référence — M11 : RBAC & Future Grants

## Source

| Fichier | Chemin source |
|---------|---------------|
| `main.tf` | `project/04-day3-rbac/environments/dev/main.tf` |
| `provider.tf` | `project/04-day3-rbac/environments/dev/provider.tf` |
| `variables.tf` | `project/04-day3-rbac/environments/dev/variables.tf` |
| Module : `rbac` | `project/03-day2-modules/modules/rbac/` |
| Module : `user-role-assignment` | `project/03-day2-modules/modules/user-role-assignment/` |

## Résultat attendu

- 6 rôles : `RL_SYSADMIN_DEV`, `RL_SECURITYADMIN_DEV`, `RL_USERADMIN_DEV`, `RL_DATA_ENGINEER_DEV`, `RL_DATA_ANALYST_DEV`, `RL_DATA_STEWARD_DEV`
- Hiérarchie : analyst → engineer → sysadmin → SYSADMIN
- Future grants sur les tables dans les bases RAW et CURATED
- `SHOW GRANTS` et `SHOW FUTURE GRANTS` retournent les entrées attendues

