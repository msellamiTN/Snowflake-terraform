# Solution de référence — M0 : Préparation de l'environnement

Aucun code Terraform à vérifier. La solution est une chaîne d'outils fonctionnelle :

- Terraform v1.14.5
- Snow CLI installé et connecté
- Azure CLI installé et authentifié
- Code d'équipe attribué
- `secrets/snowflake_key.p8` en place (si JWT) ou mot de passe configuré (si fallback)

## Traçabilité

| Élément | Source |
|---------|--------|
| Versions des outils | `docs/version-policy.md` |
| Configuration d'auth | `project/01-day1-basics/provider.tf` |
| Format de clé | `secrets/snowflake_key.p8` (PKCS#8, sans passphrase) |

