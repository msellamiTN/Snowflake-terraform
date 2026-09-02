# ✅ Résultats attendus — M2 : gestion du state

> **Contrat du lab (120 min)** — Les extraits ci-dessous sont volontairement courts et stables. Les identifiants Azure, horodatages, numéros de série, versions et durées peuvent varier : ils ne constituent pas des critères de réussite.

## 🧭 Référentiel des pistes et des clés

| Piste | Root Terraform | Clé Azure Blob attendue |
|---|---|---|
| **CORE** | environnement DEV de `APP01` | `training/APP01/dev/terraform.tfstate` |
| **COLLAB** | mini-root contenant uniquement un `terraform_data` | `training/TEAM01/collab/terraform.tfstate` |

Le backend AzureRM utilise l’authentification Microsoft Entra ID :

```hcl
use_azuread_auth = true
```

Les commandes Azure Storage utilisent :

```text
--auth-mode login
```

Le principal connecté dispose du rôle **Storage Blob Data Contributor** sur le périmètre du compte ou du conteneur.

---

## 🅰️ Scénario A — Sandbox et bootstrap du backend

### Preuve A1 — Contexte Azure valide

```bash
az account show --query "{name:name, tenantId:tenantId}" -o table
```

**Attendu :** une ligne de souscription et un tenant, sans erreur d’authentification.

### Preuve A2 — Ressources de stockage disponibles

```bash
az storage container create \
  --name <container> \
  --account-name <storage-account> \
  --auth-mode login \
  --output table
```

**Attendu — les deux résultats sont valides :**

```text
Created
-------
True
```

ou, lors d’une réexécution idempotente :

```text
Created
-------
False
```

> ✅ `Created: True` **et** `Created: False` sont acceptés. `False` signifie que le conteneur existait déjà ; ce n’est pas un échec.

### Preuve A3 — Accès data-plane

```bash
az storage blob list \
  --container-name <container> \
  --account-name <storage-account> \
  --auth-mode login \
  --query "[].name" -o tsv
```

**Attendu :** la commande aboutit. Une sortie vide est normale avant la première migration.

---

## 🅱️ Scénario B — Onboarding CORE de `APP01`

Depuis le root CORE, après configuration d’une seule méthode de backend :

```bash
terraform init -migrate-state
```

**Attendu :**

```text
Successfully configured the backend "azurerm"!
Terraform has been successfully initialized!
```

La configuration effective pointe vers :

```text
training/APP01/dev/terraform.tfstate
```

Puis :

```bash
terraform state list
terraform plan -detailed-exitcode
```

**Attendu :** les ressources M1 sont listées et le plan ne propose aucun changement.

```text
No changes. Your infrastructure matches the configuration.
```

**Code retour accepté pour le plan :** `0`. Un code `2` indique des changements et doit être diagnostiqué ; `1` indique une erreur.

### Preuve Azure CORE

```bash
az storage blob show \
  --container-name <container> \
  --account-name <storage-account> \
  --name training/APP01/dev/terraform.tfstate \
  --auth-mode login \
  --query "{name:name,size:properties.contentLength}" -o table
```

**Attendu :**

```text
Name                                           Size
---------------------------------------------  ----
training/APP01/dev/terraform.tfstate            <non-zero>
```

---

## 🅲 Scénario C — Divergence locale contrôlée

Une modification locale de configuration, sans `apply`, doit être visible dans le plan :

```bash
terraform plan -detailed-exitcode
```

**Attendu :**

```text
Plan: <n> to add, <n> to change, <n> to destroy.
```

**Code retour attendu :** `2`.

Après annulation de la divergence :

```text
No changes. Your infrastructure matches the configuration.
```

**Code retour attendu :** `0`. Le blob distant reste la source de vérité ; aucun `terraform.tfstate` local actif ne doit être recréé.

---

## 🅳 Scénario D — Collaboration et verrou Azure Blob

Le mini-root COLLAB contient uniquement un `terraform_data` et utilise :

```text
training/TEAM01/collab/terraform.tfstate
```

Après `init` et `apply`, la preuve minimale est :

```bash
terraform state list
```

```text
terraform_data.collab
```

Pendant qu’un premier processus détient le verrou, un second processus visant la même clé doit échouer :

```text
Error: Error acquiring the state lock
```

La sortie peut aussi contenir `Lock Info` ou un identifiant de verrou variable. Une fois le premier processus terminé proprement, une nouvelle commande réussit sans déverrouillage forcé.

> 🛑 Un conflit provoqué pendant cet exercice n’autorise pas automatiquement `force-unlock`.

---

## 🅴 Scénario E — Incidents d’authentification et RBAC

Sans session valide ou sans droit data-plane, une commande peut produire un message variable contenant notamment :

```text
AuthorizationPermissionMismatch
```

ou :

```text
403
```

Après reconnexion, utilisation de `--auth-mode login`, configuration `use_azuread_auth = true` et attribution/propagation du rôle **Storage Blob Data Contributor** :

```bash
az storage blob list \
  --container-name <container> \
  --account-name <storage-account> \
  --auth-mode login \
  --query "[].name" -o tsv
```

**Attendu :** code retour `0`, puis visibilité des clés déjà créées. Une courte attente peut être nécessaire après une attribution RBAC.

---

## 🅵 Scénario F — Absence de remnants locaux

Depuis chacun des roots initialisés avec le backend distant :

```bash
terraform state pull
```

**Attendu :** JSON valide, avec au minimum :

```json
{
  "version": 4,
  "serial": "<variable>",
  "lineage": "<variable>"
}
```

Les sauvegardes créées pendant la migration peuvent exister temporairement, mais aucun fichier local ne doit être utilisé comme state actif. Preuves attendues :

- le backend `azurerm` est initialisé ;
- le blob distant existe à la clé contractuelle ;
- `terraform plan` reste cohérent ;
- tout `terraform.tfstate`, `terraform.tfstate.backup` ou fichier de récupération local est inventorié, protégé puis traité selon les consignes du formateur — jamais publié dans Git.

---

## 🅶 Scénario G — DEV/UAT/PROD et `terraform_remote_state`

Les states d’environnement sont isolés par clé, selon la convention validée pendant le lab :

```text
training/APP01/dev/terraform.tfstate
training/APP01/uat/terraform.tfstate
training/APP01/prod/terraform.tfstate
```

La liste Azure doit montrer des clés distinctes :

```bash
az storage blob list \
  --container-name <container> \
  --account-name <storage-account> \
  --auth-mode login \
  --prefix training/APP01/ \
  --query "[].name" -o tsv
```

**Attendu :** une ligne par state effectivement créé, sans partage de clé entre DEV, UAT et PROD.

Le consommateur `terraform_remote_state` lit un output publié par le producteur DEV :

```bash
terraform output
```

**Attendu :** l’output consommé correspond à l’output du state DEV. Les valeurs métier varient ; l’absence d’erreur `Unable to find remote state` est le critère stable.

---

## 🅷 Scénario H — Recovery réel guidé

> 🛑 **STOP formateur obligatoire** avant toute restauration, tout `terraform force-unlock` ou tout `terraform state push -force`.

Avant l’incident simulé, les preuves sont capturées :

```bash
terraform state pull > <copie-de-recuperation-protegee>.json
terraform state list
```

Après restauration guidée d’une version saine du blob ou d’une copie validée :

```bash
terraform state pull
terraform state list
terraform plan -detailed-exitcode
```

**Attendu :**

- le JSON est lisible et correspond à la bonne clé et au bon environnement ;
- les adresses de ressources attendues réapparaissent ;
- le plan retourne `0` et affiche :

```text
No changes. Your infrastructure matches the configuration.
```

Si un plan propose une destruction ou une recréation inattendue, le recovery n’est **pas** validé : ne pas appliquer, conserver les preuves et revenir au checkpoint formateur.

## 📎 Paquet de preuves minimal

- [ ] capture du contexte Azure sans secret ;
- [ ] résultat de création du conteneur (`Created True` ou `Created False`) ;
- [ ] clés CORE et COLLAB visibles dans Azure ;
- [ ] `state list` CORE et `terraform_data.collab` ;
- [ ] plan CORE sans changement ;
- [ ] erreur de lock contrôlée puis retour à la normale ;
- [ ] incident d’authentification/RBAC et correction ;
- [ ] inventaire des remnants locaux ;
- [ ] isolation DEV/UAT/PROD et lecture `terraform_remote_state` ;
- [ ] recovery guidé avec état avant/après et plan final sans changement.

> 🔐 Ne jamais inclure dans les preuves : jetons, clés de compte de stockage, mots de passe, contenu de `.env`, fichiers de state complets ou valeurs sensibles d’outputs.
