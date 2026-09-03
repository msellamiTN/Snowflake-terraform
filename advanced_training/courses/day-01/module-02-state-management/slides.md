# Slides M2 — Sécuriser et partager le state Terraform

> Durée cible de présentation : 15 à 20 minutes avant le lab. Module complet : 2 h. Terraform : `1.14.5` exactement.

---

## Mission du module

- 🎯 **Acteur :** `TEAM01`, équipe qui collabore sur le code de `APP01` ;
- ⚠️ **Problème :** un state local peut être perdu, diverger ou exposer des données sensibles ;
- ✅ **Résultat :** un state distant isolé à la clé `training/APP01/dev/terraform.tfstate`, authentifié avec Microsoft Entra ID et protégé contre les écritures concurrentes.

> `TEAM01` est uniquement un périmètre de collaboration. Ce n’est pas une frontière ni un nom de state.

---

## Où sommes-nous ?

```mermaid
flowchart LR
    M1["M1 — Ressources créées par IaC"] --> M2["M2 — State isolé, partagé et protégé"]
    M2 --> M3["M3 — Brownfield réconcilié"]
```

**Lecture :** M2 sécurise la mémoire produite en M1 avant l’import et la réconciliation du brownfield en M3. L’ordre repose sur les flèches, pas sur une couleur.

---

## 🧠 Modèle mental : code, state, réalité

```mermaid
flowchart TB
    CODE["Code HCL — intention"]
    STATE["State — adresses ↔ identifiants"]
    REAL["Réalité — API Snowflake/Azure"]
    PLAN["terraform plan"]
    APPLY["terraform apply"]

    CODE --> PLAN
    STATE --> PLAN
    REAL -->|refresh| PLAN
    PLAN --> APPLY
    APPLY --> REAL
    APPLY -->|nouveau snapshot| STATE
```

**Lecture :** `plan` compare trois vues. `apply` modifie la réalité puis écrit un nouveau snapshot. Le state est une mémoire opérationnelle sensible, pas le code source ni une sauvegarde complète de Snowflake.

---

## 🔎 Que mémorise le state ?

- les adresses telles que `snowflake_database.raw` ;
- les identifiants réels tels que `DB_RAW_DEV` ;
- les attributs retournés par les providers et les root outputs ;
- `serial`, `lineage`, dépendances et version d’écriture ;
- parfois des valeurs sensibles, même lorsqu’elles sont marquées `sensitive`.

**Règle :** ne jamais éditer le JSON à la main ni committer `.tfstate`, `.tfstate.backup` ou une copie exportée.

---

## 🧭 Décider la frontière du state

```mermaid
flowchart TD
    START["Quel périmètre évolue ensemble ?"] --> SOLO{"Prototype jetable et opérateur unique ?"}
    SOLO -->|oui| LOCAL["State local temporaire"]
    SOLO -->|non| APP["Une APP"]
    APP --> ENV["Un environnement"]
    ENV --> TARGET["training/APP01/dev/terraform.tfstate"]
    TEAM["TEAM01 — collaboration"] -.->|revue et coordination uniquement| APP
    NEXT["APP02 ou prod"] --> OTHER["Autre clé, autre state"]
```

**Lecture :** CORE isole d’abord par application, puis par environnement. `TEAM01` organise les personnes ; il ne doit pas produire `training/TEAM01/dev/terraform.tfstate`.

---

## ⚠️ Pourquoi le local ne suffit pas

```mermaid
sequenceDiagram
    participant A as Poste A — state local
    participant API as Réalité Snowflake
    participant B as Poste B — autre state local

    A->>API: apply depuis sa lignée
    API-->>A: objet modifié
    B->>API: plan/apply depuis une autre lignée
    API-->>B: conflit ou changement inattendu
```

**Lecture :** les postes partagent une réalité mais pas leur `serial`, leur `lineage` ni un verrou distant. Copier un fichier à la main ne garantit ni cohérence ni recovery.

Risques : perte du poste, state périmé, deux sources de vérité, fuite d’attributs et blast radius excessif.

---

## 🏗️ Architecture CORE cible

```mermaid
flowchart LR
    TEAM["TEAM01 — revue et coordination"] --> CODE["Code APP01/dev"]
    ID["Identité Microsoft Entra ID"] --> TF["Terraform 1.14.5"]
    CODE --> TF
    TF -->|provider APIs| SF["Réalité Snowflake"]
    TF -->|data plane RBAC| BLOB["Blob training/APP01/dev/terraform.tfstate"]
    BLOB -->|lease sur ce même blob| TF
    POLICY["Versioning + soft delete + runbook"] --> BLOB
```

**Lecture :** Terraform accède au blob APP01/dev avec l’identité Entra ID. Le snapshot et le lease concernent le même blob ; versioning et soft delete préparent le recovery.

---

## 🔐 Entra ID : management plane ≠ data plane

```mermaid
flowchart TB
    ID["Identité Entra ID"]
    ARM["Management plane — Azure Resource Manager"]
    DATA["Data plane — Azure Blob service"]
    ADMIN["Créer/configurer compte, conteneur et rôles"]
    OPERATE["Lire/écrire le state et gérer son lease"]

    ID -->|rôle de gestion distinct| ARM
    ARM --> ADMIN
    ID -->|Storage Blob Data Contributor| DATA
    DATA --> OPERATE
```

**Lecture :** `Storage Blob Data Contributor` donne les opérations Blob nécessaires au backend, au scope minimal. Il ne crée pas le Storage Account et n’accorde pas des rôles. Un rôle de management plane ne donne pas automatiquement accès aux données Blob.

```hcl
terraform {
  required_version = "= 1.14.5"

  backend "azurerm" {
    resource_group_name  = "rg-training-tfstate"
    storage_account_name = "sttrainingtfstate"
    container_name       = "tfstate"
    key                  = "training/APP01/dev/terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

---

## 🔄 Migration contrôlée

```mermaid
flowchart LR
    CHECK["Geler et vérifier le local"] --> BACKUP["Copie de secours protégée"]
    BACKUP --> CONFIG["Configurer azurerm + clé cible"]
    CONFIG --> MIGRATE["terraform init -migrate-state"]
    MIGRATE --> VERIFY["state list + plan"]
    VERIFY --> CLEAN["Gérer les copies selon la rétention"]
```

**Lecture :** Terraform migre le snapshot entre backends ; on ne déplace pas le JSON à la main. La vérification précède le nettoyage.

```powershell
terraform init -migrate-state
terraform state list
terraform plan
```

⚠️ Certaines opérations peuvent créer un backup local, mais **la suppression automatique générale des anciens backups n’est pas garantie**. Copies, fichiers `.backup` et versions Azure ont des rétentions distinctes.

---

## 🔒 Locking : un lease, pas un conteneur séparé

```mermaid
sequenceDiagram
    participant T1 as Terraform 1
    participant B as Blob APP01/dev
    participant T2 as Terraform 2

    T1->>B: Acquire lease
    B-->>T1: accordé
    T2->>B: Acquire lease
    B-->>T2: refus / attente
    T1->>B: écrire le nouveau snapshot
    T1->>B: Release lease
```

**Lecture :** Azure place le lease sur le blob de state lui-même. Aucun conteneur de lock séparé n’est requis. Chaque clé isolée possède son propre blob et son propre lease.

`terraform force-unlock LOCK_ID` : uniquement après avoir prouvé que le writer initial est arrêté. Cette commande retire un lock ; elle ne répare pas le state.

---

## 🛟 Recovery : préparer avant l’incident

```mermaid
flowchart TD
    INCIDENT["State suspect, remplacé ou supprimé"] --> STOP["1. Stopper tous les writers"]
    STOP --> PRESERVE["2. Préserver snapshot et logs"]
    PRESERVE --> SELECT["3. Sélectionner une version Azure cohérente"]
    SELECT --> RESTORE["4. Restaurer selon le runbook"]
    RESTORE --> VALIDATE["5. state list + plan + contrôle Snowflake"]
    VALIDATE --> DECIDE{"Résultat conforme ?"}
    DECIDE -->|oui| RESUME["6. Reprise approuvée"]
    DECIDE -->|non| ESCALATE["Escalade ; pas de state push improvisé"]
```

**Lecture :** versioning et soft delete fournissent des candidats à la restauration seulement s’ils étaient activés et encore dans leur rétention. La reprise exige une comparaison avec la réalité.

À définir en production : RPO/RTO, rétention, propriétaires, accès d’urgence, double approbation et test périodique du runbook.

---

## 🔗 `terraform_remote_state` : attention à la portée

```mermaid
flowchart LR
    PRODUCER["Stack productrice"] -->|ressources + root outputs| SNAPSHOT["Snapshot complet"]
    CONSUMER["Stack consommatrice"] -->|accès requis au snapshot complet| SNAPSHOT
    SNAPSHOT -->|outputs exposés par la data source| VALUES["Valeurs consommées"]
```

**Lecture :** la data source expose uniquement les root outputs, mais son identité doit pouvoir lire le snapshot complet. Un output `sensitive` n’est pas une barrière d’accès au fichier.

**Production :** préférer une publication explicite dans une interface dédiée — Key Vault pour les secrets, App Configuration, DNS ou catalogue — lorsque les niveaux de confiance diffèrent.

---

## 🏭 Training versus Production

| Dimension | Training | Production |
|---|---|---|
| Identité | Session Entra ID du lab | Workload identity/OIDC ou managed identity par pipeline |
| State | `training/APP01/dev/terraform.tfstate` | Clés APP/env gouvernées et blast radius documenté |
| RBAC | `Storage Blob Data Contributor` au scope pédagogique minimal | Scope minimal, groupes dédiés, revues et accès d’urgence audité |
| Réseau | Endpoint accessible au lab | Firewall/private endpoint et DNS validés pour les runners |
| Recovery | Observer et comprendre les protections | Versioning, soft delete, alertes, rétention et restores testés |
| Exécution | Checkpoints interactifs | Pipeline sérialisée, approvals et logs |
| Données partagées | `terraform_remote_state` à but pédagogique | Interface dédiée privilégiée |

---

## 🛡️ Sécurité, coût et bonnes pratiques

- 🔐 **Identité :** `use_azuread_auth = true`, aucune Storage access key dans Git.
- 👤 **Least privilege :** `Storage Blob Data Contributor` pour le data plane ; management plane séparé.
- 🧩 **Isolation :** une clé par APP et environnement ; `TEAM01` reste la collaboration.
- 🗄️ **Protection :** chiffrement Azure, versioning, soft delete et rétention explicite.
- 🌐 **Réseau :** l’endpoint Blob doit être joignable par le runner autorisé.
- 💰 **Coût :** versions, rétention, logs, réplication et private endpoints peuvent s’accumuler.
- 🧹 **Cleanup :** ne supprimer le backend ou les backups qu’après validation et selon la politique.

---

## ✅ Checkpoint final

L’apprenant doit pouvoir affirmer et prouver :

- Terraform utilisé : `1.14.5` ;
- clé CORE : `training/APP01/dev/terraform.tfstate` ;
- `TEAM01` : collaboration uniquement ;
- authentification : Microsoft Entra ID avec `use_azuread_auth = true` ;
- rôle data plane : `Storage Blob Data Contributor` ;
- locking : lease sur le blob de state, sans conteneur de lock séparé ;
- recovery : versioning/soft delete plus runbook, jamais une garantie de backup éternel ;
- remote state : lecture des outputs, mais accès nécessaire au snapshot complet.

---

## 🚀 Votre prochaine action

Ouvrez le [lab M2](./lab.md), vérifiez le preflight et identifiez **avant toute migration** :

1. le state local source ;
2. l’identité Entra ID active ;
3. la clé cible exacte `training/APP01/dev/terraform.tfstate`.

Références : [backend `azurerm`](https://developer.hashicorp.com/terraform/language/backend/azurerm), [state locking](https://developer.hashicorp.com/terraform/language/state/locking), [Azure Blob RBAC](https://learn.microsoft.com/azure/storage/blobs/assign-azure-role-data-access), [blob versioning](https://learn.microsoft.com/azure/storage/blobs/versioning-overview).
