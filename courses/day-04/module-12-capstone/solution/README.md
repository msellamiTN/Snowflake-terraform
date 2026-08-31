# Solution de référence — M12 : Capstone

## Source

| Fichier | Chemin source |
|---------|---------------|
| Capstone DEV | `project/05-capstone/environments/dev/` |
| Capstone TEST | `project/05-capstone/environments/test/` |
| Data Mesh spokes | `project/05-capstone/environments/dev/data-mesh-spokes.tf` |
| FinOps dbt | `finops/` |
| CI/CD ADO | `azure-pipelines.yml` |
| CI/CD GH Actions | `.github/workflows/terraform.yml` |

## Résultat attendu

- Plateforme complète déployée : landing zone + RBAC + sécurité + file formats + network policy
- Data Mesh spokes (si configuré) : bases de domaines, schémas, warehouses, monitors
- dbt FinOps : 9 modèles (4 vues staging + 5 tables mart), tous les tests réussissent
- Zero drift : `terraform plan -detailed-exitcode` retourne 0
- Tous les noms suivent la convention `ENV_TEAM_ROLE`
- Pipeline CI/CD : validate → plan → apply → audit (avec dbt)

## Traçabilité

| Composant | Module | Racine source |
|-----------|--------|---------------|
| Landing zone | M5 | `project/03-day2-modules/modules/landing-zone/` |
| RBAC | M11 | `project/03-day2-modules/modules/rbac/` |
| Key Vault | M10 | `project/03-day2-modules/modules/key-vault-rsa/` |
| Crypto (formation) | M10 | `project/03-day2-modules/modules/crypto/` |
| Rôles utilisateurs | M6 | `project/03-day2-modules/modules/user-role-assignment/` |
| Data Mesh | M12 | `project/05-capstone/environments/dev/data-mesh-spokes.tf` |
| FinOps | M12 | `finops/` |
| CI/CD | M7 | `azure-pipelines.yml`, `.github/workflows/terraform.yml` |

