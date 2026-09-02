# 🧰 Dépannage — M2 : gestion du state

> **Lab de 120 min — scénarios A à H.** Procéder dans l’ordre des checkpoints. Capturer uniquement des preuves non sensibles. Ne jamais afficher ni partager une clé de stockage, un jeton, un mot de passe, le contenu de `.env` ou un state complet.

## 🧭 Checkpoint 0 — Outillage et bon dossier

### Terraform absent du `PATH` ou mauvaise version

- **Symptôme** — `terraform` n’est pas reconnu, ou `terraform init` refuse `required_version`.
- **Cause** — Terraform n’est pas installé, le terminal n’a pas rechargé le `PATH`, ou un autre exécutable est prioritaire.
- **Diagnostic** — Exécuter `terraform version` puis `Get-Command terraform -All` sous PowerShell, ou `command -v terraform` sous Bash. Comparer la version à `required_version` sans modifier le code.
- **Correction** — Utiliser la version prévue par le poste de formation, rouvrir le terminal après installation, puis revérifier `terraform version`.
- **Prévention** — Valider Azure CLI et Terraform au début du lab et conserver la sortie de version comme preuve.

### Commande lancée dans le mauvais dossier

- **Symptôme** — `No configuration files`, un state inattendu, zéro ressource, ou un plan qui concerne un autre environnement.
- **Cause** — La commande est lancée hors du root CORE, COLLAB ou du consommateur `terraform_remote_state`.
- **Diagnostic** — Afficher le dossier courant (`Get-Location` ou `pwd`) et vérifier la présence des fichiers `.tf`. Exécuter `terraform state list` seulement après avoir confirmé le root et la clé attendue.
- **Correction** — Arrêter la commande, se placer dans le root voulu et relancer `terraform init`. CORE doit viser `training/APP01/dev/terraform.tfstate` ; COLLAB doit viser `training/TEAM01/collab/terraform.tfstate`.
- **Prévention** — Inscrire le root, l’environnement et la clé dans chaque capture de preuve ; utiliser un terminal clairement nommé par root.

## 🅰️ Checkpoint A — Sandbox et backend Azure

### Région Azure indisponible

- **Symptôme** — La création du resource group ou du storage account échoue avec `The selected region is currently not accepting new customers`, `LocationNotAvailableForResourceType` ou un message équivalent.
- **Cause** — La région choisie est temporairement fermée ou ne propose pas la ressource pour cette souscription.
- **Diagnostic** — Exécuter `az account list-locations --query "[].name" -o table`, puis vérifier les régions autorisées par le formateur.
- **Correction** — Choisir une région disponible approuvée, mettre à jour la variable de région et recréer uniquement la ressource qui a échoué.
- **Prévention** — Tester la région au checkpoint sandbox et prévoir une région de repli pour la session.

### Création du conteneur retourne `Created: False`

- **Symptôme** — La commande n’affiche pas `True`.
- **Cause** — Le conteneur existe déjà ; la commande est idempotente.
- **Diagnostic** — Lister le conteneur avec `--auth-mode login` et vérifier que la commande retourne un code `0`.
- **Correction** — Aucune si l’accès réussit. `Created: True` et `Created: False` sont tous deux valides.
- **Prévention** — Ne pas supprimer un conteneur partagé pour obtenir artificiellement `True`.

## 🅱️ Checkpoint B — Initialisation et migration CORE

### Méthodes de backend mélangées

- **Symptôme** — `terraform init` signale une configuration dupliquée/incohérente, demande des valeurs inattendues ou utilise une mauvaise clé.
- **Cause** — Les valeurs sont présentes dans `backend.tf` **et** injectées avec `-backend-config`, ou une ancienne initialisation subsiste dans `.terraform`.
- **Diagnostic** — Sans afficher de secrets, déterminer la méthode choisie : soit backend complet dans `backend.tf`, soit bloc partiel et fichier `backend.hcl`. Examiner la commande réellement lancée.
- **Correction** — Garder une seule méthode. Si la configuration effective change, lancer `terraform init -reconfigure` ; employer `-migrate-state` uniquement lorsqu’un state doit réellement être migré et après vérification de la source et de la destination.
- **Prévention** — Documenter la méthode retenue par root et ne jamais combiner backend complet et `backend.hcl`.

### `backend.hcl` manquant

- **Symptôme** — `Failed to read file`, `no such file or directory`, ou Terraform demande les paramètres du backend.
- **Cause** — La commande utilise `-backend-config="backend.hcl"`, mais le fichier n’existe pas dans le root courant ou porte un autre nom.
- **Diagnostic** — Confirmer le dossier courant et tester uniquement l’existence du fichier ; ne pas imprimer son contenu dans les preuves.
- **Correction** — Si la méthode partielle a été choisie, créer/placer localement le fichier prévu à partir du modèle non secret. Sinon, retirer `-backend-config` et utiliser la méthode backend complet.
- **Prévention** — Ajouter un contrôle d’existence avant `init` et garder les fichiers de paramètres sensibles hors de Git.

### Compte, conteneur ou clé incorrects

- **Symptôme** — `storage account not found`, `container not found`, `blob not found`, ou toutes les ressources apparaissent `to create` après migration.
- **Cause** — Nom de stockage erroné, mauvais conteneur, faute de casse/chemin, ou confusion entre CORE et COLLAB.
- **Diagnostic** — Comparer les métadonnées non sensibles du backend à la convention. CORE : `training/APP01/dev/terraform.tfstate`. COLLAB : `training/TEAM01/collab/terraform.tfstate`. Lister les noms de blobs avec `--auth-mode login`.
- **Correction** — Ne pas appliquer. Corriger la cible, puis réinitialiser avec `terraform init -reconfigure` ou refaire une migration contrôlée si nécessaire.
- **Prévention** — Faire valider la matrice root → conteneur → clé avant la première migration.

## 🅲 Checkpoint C — Divergence locale

### Le plan propose des changements inattendus

- **Symptôme** — `terraform plan -detailed-exitcode` retourne `2` alors qu’aucune divergence n’est attendue.
- **Cause** — Modification locale non annulée, variables différentes, mauvais root, mauvais state ou drift réel.
- **Diagnostic** — Lire le plan sans l’appliquer ; identifier l’adresse, l’action et la valeur d’entrée concernées. Vérifier dossier, variables et clé de backend avant de conclure à un drift.
- **Correction** — Annuler la modification d’exercice ou rétablir les bonnes entrées. En cas de drift réel, arrêter et soumettre le plan au formateur.
- **Prévention** — Utiliser une divergence petite et réversible, et capturer un plan à `0` avant puis après l’exercice.

## 🅳 Checkpoint D — Collaboration et verrou

### Verrou normal détenu par un autre processus

- **Symptôme** — `Error acquiring the state lock` pendant qu’un autre terminal travaille sur la même clé.
- **Cause** — Le lease Azure Blob protège le state contre les écritures concurrentes.
- **Diagnostic** — Identifier le détenteur via `Lock Info`, puis demander à l’équipe si un `plan` ou `apply` est encore actif. Ne pas casser le lease pendant une opération active.
- **Correction** — Attendre la fin propre du premier processus, puis relancer. C’est le résultat attendu du scénario de lock.
- **Prévention** — Annoncer les opérations d’écriture et utiliser exactement la clé COLLAB `training/TEAM01/collab/terraform.tfstate` pour l’exercice coordonné.

### Lock obsolète après interruption

- **Symptôme** — L’erreur de lock persiste alors qu’aucun processus n’est actif.
- **Cause** — Processus interrompu ou lease/lock devenu obsolète.
- **Diagnostic** — Vérifier avec tous les participants qu’aucune opération ne tourne, conserver l’ID du lock et confirmer la bonne clé. Réessayer après une courte attente.
- **Correction** — 🛑 **STOP et approbation explicite du formateur.** Seulement après preuve qu’aucune écriture n’est active, exécuter `terraform force-unlock <LOCK_ID>` depuis le bon root. Ne jamais utiliser `-force` par réflexe.
- **Prévention** — Laisser les commandes se terminer, éviter de fermer brutalement le terminal et journaliser le propriétaire du lock.

## 🅴 Checkpoint E — Authentification et RBAC

### Azure CLI demande une clé ou signale des credentials absents

- **Symptôme** — La commande Storage demande un account key, affiche `No credentials found` ou tente de récupérer les clés du compte.
- **Cause** — `--auth-mode login` est absent ou la session Azure CLI n’est pas valide.
- **Diagnostic** — Vérifier `az account show` et la présence de `--auth-mode login` dans la commande, sans afficher de jeton.
- **Correction** — Se reconnecter avec le mécanisme de formation puis relancer la commande avec `--auth-mode login`.
- **Prévention** — Standardiser toutes les commandes Azure Storage du lab avec `--auth-mode login`.

### Terraform n’utilise pas Microsoft Entra ID

- **Symptôme** — Le backend recherche une access key/SAS, ou retourne une erreur d’authentification malgré une session Azure valide.
- **Cause** — `use_azuread_auth = true` manque dans la configuration AzureRM effective.
- **Diagnostic** — Vérifier la configuration backend choisie sans exposer de données sensibles, puis confirmer que `use_azuread_auth` vaut `true`.
- **Correction** — Ajouter `use_azuread_auth = true`, puis lancer `terraform init -reconfigure` depuis le bon root.
- **Prévention** — Inclure ce paramètre dans la revue de backend avant migration.

### `403`, `AuthorizationPermissionMismatch` ou propagation RBAC

- **Symptôme** — L’identité est connectée mais ne peut pas lister/lire/écrire les blobs.
- **Cause** — Le rôle data-plane manque, est attribué au mauvais principal/périmètre, ou n’est pas encore propagé.
- **Diagnostic** — Confirmer l’identité active et faire vérifier l’attribution **Storage Blob Data Contributor** au niveau du compte ou du conteneur. Distinguer ce rôle d’un rôle management-plane tel que `Contributor`.
- **Correction** — Faire attribuer le bon rôle au bon principal et au bon scope, puis attendre la propagation et retester périodiquement. Ne pas contourner avec une clé de stockage.
- **Prévention** — Attribuer le rôle avant le lab et prévoir le délai de propagation RBAC dans le checkpoint A.

## 🅵 Checkpoint F — Remnants locaux

### `terraform.tfstate` ou sauvegardes locales après migration

- **Symptôme** — Un `terraform.tfstate`, `terraform.tfstate.backup` ou fichier de récupération reste dans le root.
- **Cause** — Sauvegarde de migration, ancien state local, commande de récupération ou initialisation dans le mauvais dossier.
- **Diagnostic** — Inventorier les noms, tailles et dates sans publier leur contenu. Vérifier ensuite le backend actif avec `terraform state pull`, l’existence du blob contractuel et un plan sans changement.
- **Correction** — Ne rien supprimer tant que la migration n’est pas prouvée. Protéger la copie, obtenir l’accord formateur, puis l’archiver ou la supprimer selon la procédure du lab. Ne jamais la committer.
- **Prévention** — Ignorer les states et fichiers de récupération dans Git, et effectuer les exports uniquement vers un emplacement protégé.

## 🅶 Checkpoint G — DEV/UAT/PROD et remote state

### Environnements qui partagent accidentellement une clé

- **Symptôme** — Une opération UAT/PROD modifie les ressources DEV, ou les mêmes ressources apparaissent dans plusieurs roots.
- **Cause** — Clé backend copiée sans remplacer l’environnement.
- **Diagnostic** — Comparer les clés effectives aux conventions `training/APP01/dev/terraform.tfstate`, `training/APP01/uat/terraform.tfstate` et `training/APP01/prod/terraform.tfstate`.
- **Correction** — Ne pas appliquer. Corriger la clé puis réinitialiser avec prudence ; si un state a déjà été écrit sur la mauvaise clé, passer au checkpoint H avec le formateur.
- **Prévention** — Revue croisée de la matrice environnement → clé et interdiction des clés partagées.

### `terraform_remote_state` ne trouve pas le state ou un output

- **Symptôme** — `Unable to find remote state`, output absent ou accès refusé.
- **Cause** — Mauvaise clé/configuration backend, producteur non appliqué, output non publié, ou RBAC incomplet.
- **Diagnostic** — Vérifier séparément : existence du blob DEV, accès Entra ID, clé du consommateur et présence du nom d’output dans `terraform output` côté producteur.
- **Correction** — Corriger la référence, publier explicitement l’output nécessaire côté producteur, puis réinitialiser/planifier le consommateur. Ne pas exposer un output sensible comme preuve.
- **Prévention** — Contractualiser les noms d’outputs et tester la lecture avec une valeur non sensible.

## 🅷 Checkpoint H — Recovery réel guidé

### State distant manquant, corrompu ou mauvaise version restaurée

- **Symptôme** — `state pull` échoue, le JSON est invalide, les ressources disparaissent de `state list`, ou le plan propose des créations/destructions massives.
- **Cause** — Blob supprimé/altéré, restauration de la mauvaise clé/version, copie appartenant à un autre lineage ou environnement.
- **Diagnostic** — 🛑 **STOP : ne pas appliquer.** Capturer les métadonnées non sensibles, la clé, le plan, l’historique/version du blob et les copies candidates. Vérifier le `lineage`, le `serial`, les adresses de ressources et l’environnement hors de toute sortie publique.
- **Correction** — Avec approbation et supervision du formateur, préserver d’abord le blob/copie actuel, sélectionner une version saine, restaurer par le mécanisme Azure prévu ou par la procédure Terraform validée, puis exécuter `state pull`, `state list` et `plan`. `terraform state push -force <fichier-validé>` n’est autorisé **qu’après STOP et approbation explicite**, lorsque les contrôles de lineage/serial et la sauvegarde sont documentés.
- **Prévention** — Activer les mécanismes de protection/versionnement prévus, tester les restaurations, conserver des preuves hors Git et appliquer le moindre privilège.

### Le plan post-recovery n’est pas vide

- **Symptôme** — Le plan final retourne `2` ou propose une action destructive inattendue.
- **Cause** — Recovery incomplet, version incorrecte, configuration/variables divergentes ou drift réel.
- **Diagnostic** — Comparer `state list` avant/après, vérifier la bonne clé et analyser chaque action du plan. Ne pas masquer le problème avec un nouvel import ou un push forcé.
- **Correction** — Ne pas appliquer. Revenir au checkpoint STOP, conserver toutes les copies et faire choisir la suite par le formateur.
- **Prévention** — Définir comme critère de sortie un `terraform plan -detailed-exitcode` à `0` et une revue des ressources critiques.

## 🛑 Règle de sécurité absolue

Les commandes suivantes sont des opérations d’exception, jamais des étapes de dépannage ordinaires :

```text
terraform force-unlock <LOCK_ID>
terraform state push -force <fichier-validé>
```

Elles exigent toutes les deux : **STOP**, approbation explicite du formateur, confirmation du root et de la clé, absence d’écriture concurrente, copie de sécurité protégée et preuves avant/après. En cas de doute, ne pas exécuter.
