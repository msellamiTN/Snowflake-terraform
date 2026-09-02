# 🎓 Solution formateur — M2 : gestion du state

> **Format : checklist de validation et preuves pour un lab de 120 min.** Ce document n’est pas un workspace Terraform complet à copier. Il ne fournit ni identifiants, ni state, ni fichier de backend prêt à l’emploi.

## 🧭 Contrat à faire respecter

| Élément | Valeur attendue |
|---|---|
| Root **CORE** | environnement DEV de `APP01` |
| Clé CORE | `training/APP01/dev/terraform.tfstate` |
| Root **COLLAB** | mini-root avec un seul `terraform_data` |
| Clé COLLAB | `training/TEAM01/collab/terraform.tfstate` |
| Auth backend | `use_azuread_auth = true` |
| Auth Azure Storage CLI | `--auth-mode login` |
| RBAC data-plane | **Storage Blob Data Contributor** au scope approprié |
| Isolation | clés distinctes DEV/UAT/PROD |
| Recovery | réel, guidé et soumis à un STOP formateur |

## ⏱️ Cadencement indicatif — 120 min

| Séquence | Durée | Scénario |
|---|---:|---|
| Brief sécurité, sandbox et bootstrap | 15 min | A |
| Onboarding et migration CORE | 20 min | B |
| Divergence locale | 10 min | C |
| Mini-root COLLAB et lock | 20 min | D |
| Incidents auth/RBAC | 15 min | E |
| Recherche des remnants locaux | 10 min | F |
| DEV/UAT/PROD et `terraform_remote_state` | 15 min | G |
| Recovery réel guidé et débrief | 15 min | H |

## 📋 Checklist avant la séance

- [ ] Confirmer que Terraform et Azure CLI sont installés dans les versions prévues.
- [ ] Confirmer la région Azure disponible et une région de repli.
- [ ] Confirmer le compte de stockage, le conteneur et la convention de clés, sans diffuser de secret.
- [ ] Confirmer que les identités apprenantes ont **Storage Blob Data Contributor** sur le bon périmètre.
- [ ] Anticiper le délai de propagation RBAC.
- [ ] Vérifier que les commandes de stockage du support utilisent `--auth-mode login`.
- [ ] Vérifier que le backend utilise `use_azuread_auth = true`.
- [ ] Préparer le mini-root COLLAB avec **uniquement** un `terraform_data` ; ne pas distribuer une solution complète à copier.
- [ ] Vérifier le mécanisme Azure retenu pour l’historique/restauration du blob.
- [ ] Définir l’emplacement protégé des copies de recovery, hors Git.
- [ ] Désigner qui peut donner l’approbation STOP pour `force-unlock` et `state push -force`.

## 🅰️ Scénario A — Sandbox

### Validation formateur

- [ ] L’apprenant confirme sa souscription et son tenant sans exposer de jeton.
- [ ] Le resource group et le storage account sont disponibles dans une région autorisée.
- [ ] La création du conteneur aboutit avec `Created: True` **ou** `Created: False`.
- [ ] Une liste de blobs avec `--auth-mode login` retourne un code `0`.
- [ ] L’apprenant explique la différence entre management-plane et data-plane.

### Preuves à collecter

- sortie courte de `az account show` limitée au nom/tenant ;
- ligne `Created` du conteneur ;
- commande de liste réussie, même vide.

## 🅱️ Scénario B — Onboarding CORE

### Validation formateur

- [ ] Le terminal est dans le root CORE, pas dans un dossier parent ou dans COLLAB.
- [ ] Une seule méthode backend est utilisée : backend complet **ou** backend partiel avec `backend.hcl`.
- [ ] La clé est exactement `training/APP01/dev/terraform.tfstate`.
- [ ] Le backend contient `use_azuread_auth = true`.
- [ ] La migration conserve les ressources déjà gérées.
- [ ] `terraform plan -detailed-exitcode` retourne `0` après migration.

### Preuves à collecter

- succès court de `terraform init -migrate-state` ;
- noms de ressources via `terraform state list` ;
- existence et taille non nulle du blob CORE ;
- ligne `No changes` et code retour `0`.

> 🔎 Ne pas accepter comme preuve une capture d’un state complet : il peut contenir des données sensibles.

## 🅲 Scénario C — Divergence locale

### Validation formateur

- [ ] Un changement de configuration petit, identifié et réversible produit un code retour `2`.
- [ ] Aucun `apply` n’est lancé pour cette divergence pédagogique.
- [ ] Le changement est annulé et le plan retourne ensuite `0`.
- [ ] L’apprenant distingue divergence de configuration, drift réel et mauvaise clé de state.

### Preuves à collecter

- résumé du plan divergent, sans valeur sensible ;
- résumé final `No changes`.

## 🅳 Scénario D — Mini-root COLLAB et lock

### Validation formateur

- [ ] Le root COLLAB contient seulement un `terraform_data` pédagogique.
- [ ] Sa clé est exactement `training/TEAM01/collab/terraform.tfstate`.
- [ ] `terraform state list` contient `terraform_data.collab`.
- [ ] Deux participants ciblent volontairement la même clé COLLAB.
- [ ] Le second observe `Error acquiring the state lock` pendant la détention du lock.
- [ ] Après fin propre du premier processus, la commande du second réussit.
- [ ] Aucun déverrouillage forcé n’est utilisé pour le cas nominal.

### Preuves à collecter

- clé COLLAB visible dans Azure ;
- adresse `terraform_data.collab` ;
- erreur courte de lock, sans exiger un ID stable ;
- retour à la normale après libération.

## 🅴 Scénario E — Incidents d’authentification

### Validation formateur

- [ ] L’incident de session Azure invalide est distingué d’un incident RBAC.
- [ ] L’absence de `--auth-mode login` est diagnostiquée puis corrigée.
- [ ] L’absence de `use_azuread_auth = true` est diagnostiquée puis corrigée.
- [ ] Un `403` data-plane conduit à vérifier **Storage Blob Data Contributor**, pas seulement `Contributor`.
- [ ] Le délai de propagation RBAC est pris en compte sans contournement par account key.

### Preuves à collecter

- message d’erreur court et non sensible ;
- identité active limitée aux métadonnées utiles ;
- commande corrigée et accès blob réussi.

## 🅵 Scénario F — Remnants locaux

### Validation formateur

- [ ] L’apprenant inventorie les `terraform.tfstate`, backups et exports locaux sans en afficher le contenu.
- [ ] Le backend actif, le blob contractuel et le plan à `0` sont vérifiés avant toute suppression.
- [ ] Les copies nécessaires sont protégées hors Git.
- [ ] Aucun fichier de state ou de recovery n’est ajouté au dépôt.

### Preuves à collecter

- inventaire limité aux chemins/noms, tailles et dates ;
- preuve de state distant actif ;
- résultat de la décision formateur : conserver, archiver ou supprimer.

## 🅶 Scénario G — DEV/UAT/PROD et `terraform_remote_state`

### Validation formateur

- [ ] Les trois environnements utilisent des clés distinctes selon la convention :
  - `training/APP01/dev/terraform.tfstate` ;
  - `training/APP01/uat/terraform.tfstate` ;
  - `training/APP01/prod/terraform.tfstate`.
- [ ] Aucun root ne partage accidentellement la clé d’un autre environnement.
- [ ] Le producteur DEV publie un output non sensible prévu par le contrat.
- [ ] Le consommateur `terraform_remote_state` vise explicitement le state DEV.
- [ ] La valeur lue correspond à l’output du producteur.

### Preuves à collecter

- liste des noms de blobs sous `training/APP01/` ;
- nom de l’output producteur ;
- lecture réussie côté consommateur, avec valeur masquée si nécessaire.

## 🅷 Scénario H — Recovery réel guidé

### Gate STOP avant action

- [ ] Toutes les écritures Terraform sur la clé concernée sont arrêtées.
- [ ] Le root, le conteneur, la clé et l’environnement sont annoncés à voix haute et revus.
- [ ] Le state/blob actuel est préservé avant restauration.
- [ ] Les versions/copies candidates sont comparées par date, `lineage`, `serial` et adresses de ressources.
- [ ] Le formateur choisit explicitement la version saine et la méthode de restauration.
- [ ] L’approbation est consignée avant toute opération destructive ou forcée.

### Validation formateur après recovery

- [ ] `terraform state pull` produit un JSON lisible depuis la bonne clé.
- [ ] `terraform state list` retrouve les adresses attendues.
- [ ] `terraform plan -detailed-exitcode` retourne `0`.
- [ ] Aucune création/destruction inattendue n’est masquée ou appliquée.
- [ ] Les preuves avant/après et la décision de recovery sont conservées hors Git.

### Commandes d’exception

```text
terraform force-unlock <LOCK_ID>
terraform state push -force <fichier-validé>
```

> 🛑 Ces commandes ne sont **jamais** une étape automatique de la solution. Elles ne deviennent exécutables qu’après STOP, approbation explicite du formateur, confirmation qu’aucune écriture concurrente n’existe et création d’une copie de sécurité protégée. Préférer la libération normale du lock et le mécanisme de restauration/version Azure lorsqu’ils répondent à l’incident.

## 📎 Grille finale des preuves

| Scénario | Preuve minimale | Critère d’acceptation |
|---|---|---|
| A | conteneur + accès data-plane | `Created True/False`, liste code `0` |
| B | blob CORE + state list + plan | bonne clé, ressources conservées, plan `0` |
| C | plans avant/après | code `2`, puis code `0` |
| D | blob COLLAB + lock | `terraform_data.collab`, lock observé puis libéré |
| E | incident et correction | Entra ID + bon RBAC, accès rétabli |
| F | inventaire local | aucun state publié, décision documentée |
| G | clés isolées + output | DEV/UAT/PROD distincts, lecture réussie |
| H | preuves avant/après | state cohérent et plan final `0` |

## ✅ Critères de clôture

- [ ] Les clés CORE et COLLAB respectent exactement le contrat.
- [ ] Les sorties remises sont courtes, stables et expurgées de toute donnée sensible.
- [ ] `Created: True` et `Created: False` ont été traités comme résultats valides.
- [ ] Les erreurs prévues ont été diagnostiquées, pas contournées.
- [ ] Aucun `apply` inattendu, aucun `force-unlock` non approuvé et aucun `state push -force` non approuvé n’a eu lieu.
- [ ] Le recovery se termine par un plan à `0` ou reste explicitement bloqué au STOP.
- [ ] Aucun workspace complet n’a été copié depuis cette solution.
