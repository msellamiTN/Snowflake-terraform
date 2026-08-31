# Troubleshooting — M0 : environnement

Utilisez uniquement des diagnostics non destructifs. Ne partagez jamais `.env`, un PAT, une clé privée ou `config.toml` complet.

| Symptôme | Diagnostic | Correction minimale | Prévention |
|---|---|---|---|
| `terraform: command not found` | `Get-Command terraform` ou `command -v terraform` | Installer Terraform puis ouvrir un nouveau terminal | Exécuter le préflight avant J1 |
| `snow: command not found` | `Get-Command snow` ou `command -v snow` | Installer Snowflake CLI dans l’environnement prévu | Centraliser la version testée |
| `.env.example` absent | Vérifier la racine avec `git status` | Revenir à la racine du dépôt | Toujours afficher le répertoire au début |
| Placeholder détecté | Rechercher `<...>` dans `.env` sans afficher le fichier en support | Remplacer les identifiants manquants | Rejouer le contrôle local |
| `.env` non ignoré | `git check-ignore .env` | Corriger `.gitignore` avant tout commit | Checkpoint obligatoire |
| `secrets/` non ignoré | `git check-ignore secrets/probe.token` | Corriger `.gitignore` | Scan de secrets CI |
| `MFA authentication is required` | Vérifier le type de connexion, pas le secret | Recréer une connexion PAT/JWT | Ne pas utiliser password pour l’automatisation |
| `snow connection test` échoue | Vérifier nom de connexion, account, user et expiration | Corriger l’identifiant ou recréer le PAT | PAT temporaire avec expiration connue |
| `Missing network policy` | Lire les exigences du compte | Demander au formateur/admin une policy restreinte ou un bypass temporaire approuvé | Préprovisionner la sandbox |
| Accès bloqué après policy | Identifier l’IP et la policy depuis une session admin encore ouverte | Faire corriger la policy par l’administrateur | Ne jamais appliquer une policy globale depuis le lab M0 |
| `JWT token is invalid` | Vérifier horloge, user, account, format et fingerprint public | Corriger un élément à la fois | Traiter JWT au Jour 4 avec rotation |
| Workspace existe déjà | Vérifier le chemin affiché | Choisir un autre `WorkspaceRoot` | Ne pas utiliser de suppression automatique |
| Branche créée dans le dépôt du cours | `git rev-parse --show-toplevel` | Recréer le workspace sous `$HOME/Data2AI-Labs` | Garder le workspace hors du dépôt |
| Validateur Unix non exécutable | `ls -l validate.sh` | Lancer `bash validate.sh` ou ajouter le droit localement | Conserver LF et mode exécutable dans Git |

## Escalade

Communiquez uniquement : OS, version de l’outil, commande exécutée, répertoire courant, nom de connexion et message d’erreur expurgé. Ne joignez aucun fichier de credential.
