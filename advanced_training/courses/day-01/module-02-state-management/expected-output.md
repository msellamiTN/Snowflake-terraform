# ✅ Résultats attendus — M2 : gestion du state

> **Lab CORE (70 min) + stretch optionnel (50 min).** Les extraits ci-dessous sont volontairement courts et stables. Les identifiants Azure, horodatages, numéros de série, versions et durées peuvent varier : ils ne constituent pas des critères de réussite.

## 🧭 Référentiel des pistes et des clés

| Piste | Root Terraform | Clé Azure Blob attendue |
|---|---|---|
| **CORE** | environnement DEV de `APP01` | `training/APP01/dev/terraform.tfstate` |
| **COLLAB** (stretch) | mini-root contenant uniquement un `terraform_data` | `training/TEAM01/collab/terraform.tfstate` |

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

# Partie A — CORE obligatoire (70 min)

## 🅰️ Scénario A — Sandbox et migration

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

### Preuve A4 — Migration du state local

```bash
terraform init -migrate-state
```

**Attendu :**

```text
Successfully configured the backend "azurerm"!
Terraform has automatically migrated your state from "local" to "azurerm".
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

## � Scénario F — Preuves distantes

### Preuve F1 — Blob APP visible

```bash
az storage blob list \
  --container-name <container> \
  --account-name <storage-account> \
  --auth-mode login \
  --prefix training/APP01/ \
  --query "[].name" -o tsv
```

**Attendu :** `training/APP01/dev/terraform.tfstate` apparaît.

### Preuve F2 — Métadonnées du state

```bash
terraform state pull
```

**Attendu :** JSON valide, avec au minimum :

```json
{
  "version": 4,
  "terraform_version": "1.14.5",
  "serial": "<variable>",
  "lineage": "<variable>"
}
```

### Preuve F3 — Nouveau terminal retrouve le state

Depuis un nouveau terminal, après `Learner-Login` :

```bash
terraform init
terraform state list
terraform plan -detailed-exitcode
```

**Attendu :** mêmes trois ressources M1, `No changes`, code retour `0`.

## 🅳 Scénario D — Verrou Azure Blob (Blob Lease)

Pendant qu’un premier processus détient le verrou sur la clé CORE, un second processus visant la même clé doit échouer :

```text
Error: Error acquiring the state lock
```

La sortie peut aussi contenir `Lock Info` ou un identifiant de verrou variable. Une fois le premier processus terminé proprement (`Ctrl+C`), une nouvelle commande réussit sans déverrouillage forcé.

```text
No changes. Your infrastructure matches the configuration.
```

> 🛑 Un conflit provoqué pendant cet exercice n’autorise pas automatiquement `force-unlock`.

---

# Partie B — Stretch optionnel (+ 50 min)

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

## � Scénario C — Divergence locale contrôlée

Deux dossiers avec le même code `terraform_data.demo` mais des states locaux différents :

- Dossier A : `terraform state list` affiche `terraform_data.demo`.
- Dossier B : `terraform plan` propose `1 to add`.

**Attendu :** B propose une création malgré un code identique. Le state local crée une divergence.

## �️ Scénario B — Collaboration TEAM01

Le mini-root COLLAB contient uniquement un `terraform_data` et utilise :

```text
training/TEAM01/collab/terraform.tfstate
```

Après `init` et `apply`, la preuve minimale est :

```bash
terraform state list
```

```text
terraform_data.shared_marker
```

Le second développeur, après `terraform init` (sans `-migrate-state`), obtient :

```text
terraform_data.shared_marker
```

et `terraform plan` retourne `No changes`.

## 🅶 Scénario G — `terraform_remote_state`

Le consommateur `terraform_remote_state` lit un output publié par le producteur DEV :

```bash
terraform output raw_database_name
```

**Attendu :** l’output consommé correspond à l’output du state DEV. Les valeurs métier varient ; l’absence d’erreur `Unable to find remote state` est le critère stable.

> 💡 **Note** : l'isolation DEV/UAT/PROD par clé distincte est traitée dans M8.

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

---

## 📎 Paquet de preuves minimal

**CORE (obligatoire) :**

- [ ] capture du contexte Azure sans secret ;
- [ ] résultat de création du conteneur (`Created True` ou `Created False`) ;
- [ ] clé CORE visible dans Azure ;
- [ ] `state list` CORE avec les trois ressources M1 ;
- [ ] plan CORE sans changement (code `0`) ;
- [ ] erreur de lock contrôlée puis retour à la normale.

**Stretch (optionnel) :**

- [ ] incident d’authentification/RBAC et correction ;
- [ ] divergence locale observée (A connaît, B propose `1 to add`) ;
- [ ] `state list` COLLAB avec `terraform_data.shared_marker` ;
- [ ] lecture `terraform_remote_state` réussie ;
- [ ] recovery guidé avec état avant/après et plan final sans changement.

> 🔐 Ne jamais inclure dans les preuves : jetons, clés de compte de stockage, mots de passe, contenu de `.env`, fichiers de state complets ou valeurs sensibles d’outputs.
