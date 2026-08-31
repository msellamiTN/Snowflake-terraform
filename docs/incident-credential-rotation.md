# Procédure de rotation après exposition d'un credential

> **Statut : rotation non encore effectuée.** Le mot de passe exposé reste valide et exploitable jusqu'à son remplacement.

## 1. Constat

| Élément | Valeur |
|---|---|
| Fichier concerné | `lab00.ps1`, racine du dépôt |
| Contenu exposé | Mot de passe en clair d'un utilisateur Snowflake, identifiant de compte, identifiant d'organisation, nom d'utilisateur, rôle |
| Commit d'introduction | `a43285b` |
| Diffusion | Poussé sur la branche par défaut du dépôt distant |
| Durée d'exposition | Depuis le commit d'introduction jusqu'à la purge de l'historique |
| Purge de l'historique | Effectuée; trois commits réécrits et branche distante mise à jour de force |

## 2. Pourquoi la purge ne suffit pas

La réécriture de l'historique retire le secret des commits futurs et actuels, mais elle **ne rend pas le mot de passe invalide**. Les scénarios suivants restent possibles :

- le dépôt a été cloné ou forké avant la purge;
- l'ancien objet de commit reste accessible par son identifiant sur la plateforme d'hébergement pendant un certain temps;
- un mécanisme d'analyse automatique de secrets a déjà indexé la valeur;
- un cache, un miroir, une sauvegarde ou une intégration a conservé le contenu;
- la valeur figure dans l'historique local d'un poste ou dans un journal de terminal.

**Seule la rotation du credential élimine le risque.**

## 3. Rotation Snowflake

### Étape 1 — Identifier l'usage réel

Avant de changer le mot de passe, déterminer ce qui l'utilise afin d'éviter une interruption :

- connexions Snowflake CLI locales des participants;
- variables de pipeline CI/CD;
- profils dbt;
- fichiers de variables Terraform locaux;
- outils de BI ou d'ingestion.

### Étape 2 — Vérifier l'activité du compte

Dans une session disposant des privilèges d'audit, examiner l'historique de connexion de l'utilisateur concerné afin de repérer une utilisation anormale : adresses inattendues, horaires inhabituels, échecs répétés.

Les vues d'audit du schéma `ACCOUNT_USAGE` fournissent l'historique de connexion. Les données présentent une latence; une absence de trace récente ne prouve pas l'absence d'accès.

### Étape 3 — Remplacer le secret

Deux options, par ordre de préférence.

**Option A — Supprimer l'authentification par mot de passe (recommandée)**

Basculer l'utilisateur vers une authentification par paire de clés, conforme à la cible de production, puis retirer l'usage du mot de passe pour les accès programmatiques.

**Option B — Changer le mot de passe**

Générer une nouvelle valeur aléatoire longue, la stocker dans le coffre de secrets, et ne jamais la placer dans un fichier du dépôt.

Dans les deux cas, l'opération est réalisée par une personne disposant des privilèges d'administration des utilisateurs, depuis une session interactive et non depuis un script versionné.

### Étape 4 — Révoquer les jetons dérivés

Si des jetons d'accès programmatique ont été créés pour cet utilisateur, les révoquer et en émettre de nouveaux à expiration courte.

### Étape 5 — Mettre à jour les consommateurs

1. reconfigurer les connexions Snowflake CLI locales;
2. mettre à jour les variables de pipeline;
3. mettre à jour le profil dbt;
4. relancer une validation de connexion sur chaque consommateur;
5. confirmer qu'aucun consommateur n'utilise encore l'ancienne valeur.

### Étape 6 — Renforcer les contrôles

- restreindre les adresses autorisées pour cet utilisateur;
- exiger l'authentification forte pour les accès humains;
- réserver l'authentification par clé aux identités techniques;
- limiter les privilèges au strict nécessaire;
- définir une expiration pour tout jeton.

## 4. Vérification de la rotation

- [ ] l'ancienne valeur ne permet plus de se connecter;
- [ ] la nouvelle méthode d'authentification fonctionne;
- [ ] aucun consommateur n'est resté en échec;
- [ ] la nouvelle valeur est stockée uniquement dans le coffre de secrets;
- [ ] aucun fichier du dépôt ne contient de credential;
- [ ] l'historique de connexion ne montre plus d'accès inattendu.

## 5. Prévention

| Contrôle | Mise en œuvre |
|---|---|
| `.gitignore` | Exclut `.env`, `secrets/`, clés, jetons et scripts locaux de type `lab00.ps1` |
| Analyse de secrets | À activer côté plateforme et dans le pipeline avant fusion |
| Scripts de connexion | Saisie masquée, écriture dans un fichier à permissions restreintes, aucune valeur affichée |
| Supports de formation | Aucun credential, aucun identifiant de compte réel |
| Revue | Toute nouvelle valeur ressemblant à un secret bloque la fusion |

## 6. Récupération du fichier retiré

Le fichier local `lab00.ps1` a été supprimé du disque comme effet de bord de la purge de l'historique. Son contenu reste accessible dans la branche de sauvegarde locale `backup/pre-secret-purge-master`.

Sa restauration n'a toutefois aucun intérêt : la valeur qu'il contient doit être considérée comme compromise et doit être remplacée. Le script de connexion assistée du parcours Day 0 remplit le même rôle sans exposer de secret.

## 7. Nettoyage des références locales

Après validation de la rotation et de la purge, les références de sauvegarde peuvent être retirées :

- la branche locale `backup/pre-secret-purge-master`;
- les références générées par la réécriture sous `refs/original/`.

Ces suppressions sont définitives et ne doivent être réalisées qu'une fois la rotation confirmée.
