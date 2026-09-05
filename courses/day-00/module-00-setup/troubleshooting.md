# Jour 0 — Guide de troubleshooting

> [<- Jour 0](../README.md) · **M00 Setup** · [Jour 1 ->](../../day-01/module-01-iac-workflow/lab.md)

## Symptomes et diagnostics

### 1. `terraform : command not found` apres l'installation

**Diagnostic :**

```bash
# Windows
$HOME\.data2ai\bin\terraform.exe version

# Linux/macOS
$HOME/.data2ai/bin/terraform version
```

**Si la commande fonctionne avec le chemin complet :**

Le dossier n'est pas dans le PATH. Fermez et rouvrez le terminal.

**Windows :**

```powershell
[Environment]::GetEnvironmentVariable('PATH', 'User')
```

Verifiez que `$HOME\.data2ai\bin` est present. Sinon, relancez le script d'installation.

**Linux/macOS :**

Ajoutez a votre profil shell (`~/.bashrc` ou `~/.zshrc`) :

```bash
export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"
```

Puis :

```bash
source ~/.bashrc
```

---

### 2. `snow : command not found` apres l'installation

**Diagnostic :**

Snow CLI est installe dans l'environnement virtuel Python.

```bash
# Windows
$HOME\.data2ai\venv\Scripts\snow.exe --version

# Linux/macOS
$HOME/.data2ai/venv/bin/snow --version
```

**Si la commande fonctionne avec le chemin complet :**

Ajoutez le dossier `Scripts` ou `bin` du venv au PATH (voir symptome 1).

---

### 3. `dbt : command not found`

Meme cause que `snow`. dbt est installe dans le meme environnement virtuel.

```bash
# Windows
$HOME\.data2ai\venv\Scripts\dbt.exe --version

# Linux/macOS
$HOME/.data2ai/venv/bin/dbt --version
```

---

### 4. `python --version` affiche la mauvaise version

**Diagnostic :**

Le script signale `WARN` si Python n'est pas la version 3.12.

**Causes possibles :**

- Python 3.12 n'est pas installe et une autre version est trouvee (ex. 3.14);
- plusieurs versions de Python coexistent et la mauvaise est prioritaire.

**Conséquences :**

Si le venv est créé avec Python 3.13+ ou 3.14, les packages `cffi` et `pyyaml`
échoueront à s'installer car il n'existe pas de wheels pre-compilés pour ces versions
sur Windows. Voir les entrées **28** et **29** pour ce cas spécifique.

**Correction :**

Installez Python 3.12 depuis [python.org](https://www.python.org/downloads/) (Windows) ou avec votre gestionnaire de paquets (Linux/macOS).

**Linux :**

```bash
sudo apt-get update
sudo apt-get install -y python3.12 python3.12-venv
```

**macOS :**

```bash
brew install python@3.12
```

Puis relancez le script d'installation.

---

### 5. `snow sql` echoue avec `'utf-8' codec can't decode byte`

**Symptome :**

```text
'utf-8' codec can't decode byte 0x8a in position 68: invalid start byte
```

**Cause :**

La variable d'environnement `PYTHONUTF8=1` est active dans votre session PowerShell.
Elle force Python a decoder la sortie de `icacls` (qui utilise le codepage Windows,
ex. cp1252 sur Windows francais) comme UTF-8. Les caracteres accentues des noms de
groupes Windows (ex. `Administrateurs`, `Systme`) provoquent un crash.

**Correction :**

```powershell
Remove-Item Env:\PYTHONUTF8 -ErrorAction SilentlyContinue
snow sql -q 'SELECT 1' -c training
```

Si la variable n'existe pas, ouvrez un nouveau terminal (la variable a pu etre
definie par une session precedente et heritee).

> `[NOTE]` Les scripts de formation ne definissent plus `PYTHONUTF8=1`.
> Si vous avez execute une ancienne version des scripts, la variable a pu
> persister dans votre profil. Verifiez avec :
> ```powershell
> [Environment]::GetEnvironmentVariable('PYTHONUTF8', 'User')
> ```
> Si elle existe au niveau utilisateur, supprimez-la :
> ```powershell
> [Environment]::SetEnvironmentVariable('PYTHONUTF8', $null, 'User')
> ```

---

### 6. `snow sql` affiche un avertissement sur les permissions du fichier config

**Symptome :**

```text
UserWarning: Unauthorized users (Administrateurs, Systme) have access to configuration file
```

**Cause :**

Snow CLI verifie les permissions du fichier `~/.snowflake/config.toml` via `icacls`.
Si des groupes Windows ont acces en lecture, il emet un avertissement.

**Correction :**

```powershell
icacls "$env:USERPROFILE\.snowflake\config.toml" /inheritance:r
icacls "$env:USERPROFILE\.snowflake\config.toml" /grant:r "$(whoami):(F)"
icacls "$env:USERPROFILE\.snowflake\config.toml" /remove:g "Administrateurs"
```

> Le script `New-SnowflakeConnection.ps1` fait cette operation automatiquement.
> Si vous avez utilise une ancienne version du script, executez les commandes ci-dessus manuellement.

---

### 7. `snow sql` echoue avec `Permission denied` sur config.toml

**Symptome :**

```text
Configuration file seems to be corrupted. [Errno 13] Permission denied
```

**Cause :**

Les permissions du fichier `config.toml` ont ete restreintes trop severement
(ex. `icacls /inheritance:r` sans accorder d'acces a l'utilisateur courant).

**Correction :**

```powershell
icacls "$env:USERPROFILE\.snowflake\config.toml" /grant "$(whoami):(F)"
```

---

### 8. `snow connection add` echoue

**Diagnostic :**

```bash
snow connection list
```

**Causes possibles et corrections :**

| Cause | Correction |
|---|---|
| PAT expire | Demander un nouveau PAT au formateur |
| Compte incorrect | Verifier l'identifiant de compte fourni |
| Organisation incorrecte | Verifier l'identifiant d'organisation |
| Utilisateur incorrect | Verifier le nom d'utilisateur |
| Reseau bloque | Verifier la connectivite vers Snowflake |

**Test de connectivite :**

```bash
# Windows
Test-NetConnection -ComputerName <account>.snowflakecomputing.com -Port 443

# Linux/macOS
nc -zv <account>.snowflakecomputing.com 443
```

---

### 9. `snow sql` echoue avec une erreur de permission

**Symptome :**

```text
Insufficient privileges for operation
```

**Diagnostic :**

Le role utilise n'a pas les privileges necessaires.

**Correction :**

Verifiez le role attribue lors de la creation de la connexion. Pour la formation, `SYSADMIN` est le role attendu. N'utilisez pas `ACCOUNTADMIN` sauf instruction explicite du formateur.

```bash
snow sql -q 'SELECT CURRENT_ROLE()' -c training
```

---

### 10. `git clone` echoue

**Cas Windows — `~` n'est pas reconnu**

PowerShell ne developpe pas `~` en `C:\Users\<nom>`. Utilisez `$HOME` entre guillemets :

```powershell
New-Item -ItemType Directory -Path "$HOME\Data2AI-Labs" -Force | Out-Null
git clone https://github.com/msellamiTN/data-platform-starter.git "$HOME\Data2AI-Labs\data-platform"
cd "$HOME\Data2AI-Labs\data-platform"
```

Si le nom d'utilisateur contient un espace, encadrez toujours le chemin.

**Causes possibles :**

| Cause | Correction |
|---|---|
| `~` non interprete sous Windows | Utiliser `$HOME` entre guillemets |
| Chemin avec espace non quote | Encadrer le chemin de `"..."` |
| URL incorrecte | Verifier l'URL fournie par le formateur |
| Authentification requise | Le depot template est prive : configurer l'acces Git |
| Reseau bloque | Verifier la connectivite vers la plateforme Git |

**Test :**

```bash
git ls-remote https://github.com/msellamiTN/data-platform-starter.git
```

---

### 11. Le rapport contient un `FAIL` pour un outil

**Procedure :**

1. Lire la ligne `Action` dans le rapport — elle contient la procedure manuelle.
2. Suivre la procedure manuelle officielle.
3. Relancer le mode `Check` :

```bash
# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check

# Linux/macOS
./scripts/install-tools.sh --check
```

4. Si l'outil passe en `PASS`, continuer. Sinon, demander l'aide du formateur.

---

### 12. Une politique d'entreprise bloque l'installation

**Symptome :**

Le script affiche `FAIL` et la procedure manuelle, mais l'installation manuelle est egalement bloquee.

**Diagnostic :**

Le poste est gere par une politique d'entreprise qui interdit l'installation de logiciels.

**Correction :**

Demandez au formateur ou a l'administrateur du poste d'installer les outils manquants avec la procedure officielle de l'entreprise. Le script d'installation ne contourne jamais une politique de securite.

---

### 13. Le PATH est modifie mais ne persiste pas

**Windows :**

Le script modifie le PATH utilisateur, qui persiste entre les sessions. Si le PATH ne persiste pas, verifiez que vous avez les droits pour modifier les variables d'environnement utilisateur.

**Linux/macOS :**

Le script ne modifie pas automatiquement le profil shell. Ajoutez manuellement :

```bash
echo 'export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### 14. `$env:LEARNER_PREFIX` est vide dans PowerShell

**Symptome :**

```powershell
echo $env:LEARNER_PREFIX
# (vide)
```

**Cause :**

Vous avez ouvert un nouveau terminal sans relancer `Learner-Login`, ou vous etes
dans un sous-shell qui n'a pas herite des variables.

**Correction :**

Relancez le script de login depuis la racine du clone :

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
powershell -ExecutionPolicy Bypass -File .\scripts\Learner-Login.ps1 -LearnerPrefix APP01
```

> Les variables d'environnement ne persistent pas entre les sessions PowerShell.
> Vous devez relancer `Learner-Login` au debut de chaque session.

---

### 15. `Blob write access` FAIL dans le rapport de connectivite

**Symptome :**

```text
[FAIL] Blob write access
       Cannot write to container - check RBAC or access keys
```

ou :

```text
This endpoint - does not have BlobServices getProperties permission
```

**Cause :**

Le service principal partage n'a pas le role **Storage Blob Data Contributor**
sur le compte de stockage. Le role `Contributor` (management-plane) ne suffit pas
pour acceder aux blobs (data-plane). Il faut un role data-plane explicite.

**Diagnostic :**

```powershell
# Verifier les roles attribues au SP sur le storage account
$scope = az storage account show --name sadata2aitfstatemsn --resource-group rg-data2ai-tf-state --query id -o tsv
az role assignment list --scope $scope --query "[].{principal:principalId,role:roleDefinitionName}" -o table
```

**Attendu :** une ligne avec `Storage Blob Data Contributor` pour le principal du SP.

**Si le role est absent :**

C'est une action **formateur**. L'apprenant ne peut pas attribuer de role
(le SP n'a pas les droits `Microsoft.Authorization/roleAssignments/write`).

Le formateur doit :

```powershell
# Login avec un compte Owner (pas le SP)
az login

# Recuperer l'object ID du SP (PAS l'appId)
$spAppId = az ad sp list --display-name "sp-data2ai-learners" --query "[0].appId" -o tsv
$spObjectId = az ad sp show --id $spAppId --query id -o tsv

# Attribuer le role
az role assignment create `
  --role "Storage Blob Data Contributor" `
  --assignee-object-id $spObjectId `
  --assignee-principal-type ServicePrincipal `
  --scope (az storage account show --name sadata2aitfstatemsn --resource-group rg-data2ai-tf-state --query id -o tsv)
```

> `[IMPORTANT]` L'attribution de role utilise l'**object ID** du SP, pas l'appId.
> Ces deux valeurs sont differentes. Si vous utilisez l'appId, le role sera
> attribue au mauvais principal et le test echouera toujours.

**Si le role est present mais le test echoue encore :**

La propagation RBAC peut prendre **jusqu'a 10 minutes**. Attendez, puis :

```powershell
# Re-login pour rafraichir le token
powershell -ExecutionPolicy Bypass -File .\scripts\Learner-Login.ps1 -LearnerPrefix APP01
.\scripts\Test-LabConnectivity.ps1 -SkipDevOps
```

---

### 16. `az ad sp show` retourne `Insufficient privileges`

**Symptome :**

```text
Insufficient privileges to complete the operation.
```

**Cause :**

Le service principal partage n'a pas les permissions Entra ID (Graph API)
necessaires pour lire l'annuaire. C'est normal : le SP a uniquement `Contributor`
sur la subscription Azure, pas de droits directory.

**Correction :**

Aucune action necessaire. Le script `Test-LabConnectivity.ps1` ne verifie plus
le SP via `az ad sp show`. La presence des variables `ARM_CLIENT_ID` et
`ARM_TENANT_ID` dans `.env` et le succes du login Azure suffisent a prouver
que le SP est valide.

---

### 17. L'execution de scripts est desactivee

**Symptome :**

```text
Impossible de charger le fichier C:\...\Learner-Login.ps1, car
l'execution de scripts est desactivee sur ce systeme.
```

ou :

```text
running scripts is disabled on this system
```

**Cause :**

La politique d'execution PowerShell (`ExecutionPolicy`) est reglee sur `Restricted`
par defaut sur Windows. Cela bloque tous les scripts `.ps1`.

**Correction :**

Autorisez l'execution des scripts locaux pour l'utilisateur courant :

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

> `RemoteSigned` autorise les scripts locaux signes et non signes, mais bloque
> les scripts telecharges depuis Internet qui ne sont pas signes numeriquement.
> C'est le parametre standard pour un poste de formation.

Relancez ensuite le script :

```powershell
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01
```

**Alternative ponctuelle (sans changer la politique) :**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Learner-Login.ps1 -LearnerPrefix APP01
```

> Cette alternative ne persiste pas. Vous devrez l'utiliser a chaque appel.
> Preferez la correction permanente avec `Set-ExecutionPolicy`.

---

### 18. `Learner-Login` échoue avec `AADSTS7000215: Invalid client secret provided`

**Symptôme :**

```text
[INFO] Logging in with shared service principal...
[FAIL] Login failed
       ERROR: AADSTS7000215: Invalid client secret provided. Ensure the secret being sent in the request is the client secret value, not the client secret ID, for a secret added to app 'ab35eee0-5d09-4c4d-b41c-f536ce7dbdf0'. ... The error may be caused by passing a service principal certificate with --password. Please note that --password no longer accepts a service principal certificate. To pass a service principal certificate, use --certificate instead.
```

**Cause :**

1. La valeur passée pour `ARM_CLIENT_SECRET` dans `secrets/shared-sp.txt` (ou `.env`) n'est pas le secret valide de l'application Entra ID :
   - Le **Secret ID** (GUID / UUID) a été copié au lieu de la **Valeur du secret** (*Value*).
   - Le secret a expiré ou a été réinitialisé/révoqué côté Azure.
   - Des guillemets parasites (`"`, `'`) ou des espaces entourent la valeur dans le fichier.
2. L'avertissement relatif aux certificats (*"The error may be caused by passing a service principal certificate with --password"*) est un message générique produit par Azure CLI dès qu'un échec d'authentification par mot de passe survient.

**Correction (Apprenant) :**

1. Ouvrez `secrets\shared-sp.txt` à la racine de votre clone (`data-platform`) :
   ```text
   ARM_CLIENT_ID=ab35eee0-5d09-4c4d-b41c-f536ce7dbdf0
   ARM_TENANT_ID=<votre_tenant_id>
   ARM_SUBSCRIPTION_ID=<votre_subscription_id>
   ARM_CLIENT_SECRET=<valeur_du_secret_sans_guillemets>
   ```
2. Vérifiez que la valeur de `ARM_CLIENT_SECRET` ne contient ni guillemets, ni espaces superflus, et qu'il s'agit bien de la **Valeur** (ex. `wBZ8Q~ub...`) et non du **Secret ID**.
3. Si le secret a expiré ou été révoqué, demandez au formateur la version à jour de `secrets/shared-sp.txt`.

**Correction (Formateur / Administrateur) :**

Réinitialisez le secret du Service Principal dans Azure CLI ou via le portail Azure :

```bash
az ad sp credential reset --id ab35eee0-5d09-4c4d-b41c-f536ce7dbdf0 --query "password" -o tsv
```

Copiez la nouvelle valeur générée dans `secrets/shared-sp.txt` et redistribuez le fichier aux apprenants.

---

### 19. Outils préinstallés sur la VM mais `command not found` ou version incorrecte

> Ce cas concerne les **VMs préconfigurées** où le formateur a déjà installé les outils.
> L'apprenant doit **vérifier** l'installation, pas la réinstaller aveuglément.

**Diagnostic :**

```powershell
cd "$HOME\Data2AI-Labs\data-platform"
.\scripts\Test-VMReadiness.ps1 -SkipConnectivity
```

Le rapport affiche chaque outil avec son statut (`PASS` / `FAIL` / `WARN`) et la version détectée.

**Causes possibles selon la classification du rapport :**

| Catégorie | Cause | Action |
|---|---|---|
| `learner-tool` (command not found) | Le PATH n'inclut pas `$HOME\.data2ai\bin` ou `$HOME\.data2ai\venv\Scripts` | Fermez et rouvrez le terminal. Si le problème persiste, relancez `Install-Tools.ps1`. |
| `learner-tool` (version incorrecte) | La version installée ne correspond pas à la politique | Relancez `Install-Tools.ps1` (il épinglera les versions correctes). |
| `learner-tool` (runtime broken) | Le venv Snowflake CLI a été cassé par une installation dbt dans le même environnement | Relancez `Install-Tools.ps1 -Force` (recrée les deux venvs séparés). |
| `learner-config` | `.env` ou `LEARNER_PREFIX` non configuré | Suivez l'étape 5.2 du lab (configuration `.env`). |
| `credential` | PAT ou connexion Snowflake manquant | Suivez l'étape 5.3 du lab (`New-SnowflakeConnection.ps1`). |
| `instructor-side` | RBAC Blob/Key Vault manquant | **Escalade formateur** — le SP n'a pas les droits ou la propagation n'est pas effective. |

**Remédiation pour un outil cassé :**

```powershell
# Réinstaller les outils (idempotent — n'installe que ce qui manque ou est cassé)
.\scripts\Install-Tools.ps1

# Re-vérifier
.\scripts\Test-VMReadiness.ps1 -SkipConnectivity
```

**Remédiation pour un venv cassé par dbt :**

```powershell
# Forcer la recréation des deux venvs séparés (Snowflake CLI + dbt)
Remove-Item -Recurse -Force "$HOME\.data2ai\venv" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$HOME\.data2ai\venv-dbt" -ErrorAction SilentlyContinue
.\scripts\Install-Tools.ps1 -Force

# Rouvrir le terminal, puis re-vérifier
.\scripts\Test-VMReadiness.ps1 -SkipConnectivity
```

> `[NOTE]` Snowflake CLI (`>= 3.23.0`) nécessite `snowflake-connector-python >= 4.0`,
> tandis que `dbt-snowflake < 3.0.0` nécessite `snowflake-connector-python < 4.0.0`.
> Ces deux packages **ne peuvent pas coexister dans le même venv**.
> `Install-Tools.ps1` utilise deux venvs séparés (`.data2ai/venv` et `.data2ai/venv-dbt`).
> Si un apprenant a installé dbt dans le venv Snowflake CLI, le venv est cassé et
> doit être recréé avec `-Force`.

---

### 20. `Set-SnowflakePATs.ps1` échoue avec `Could not parse PAT from Snowflake output`

**Symptôme :**

```text
-- APP01 (apprenant01)
   [FAIL] Could not parse PAT from Snowflake output
         Raw output: ... "status": "Statement executed successfully." ...
```

**Cause :**

La syntaxe `ALTER USER ... ADD PROGRAMMATIC_ACCESS_TOKEN` n'est pas supportée
sur toutes les éditions Snowflake ou ne retourne pas le token dans la sortie
JSON du CLI. Le script ne peut pas extraire le PAT.

**Correction :**

Utiliser le **PAT partagé** au lieu de per-learner PATs. Voir la section
"Step 5 — Stocker le PAT partagé dans Key Vault" dans
[`instructor-setup.md`](../instructor-setup.md#6-step-5--stocker-le-pat-partagé-dans-key-vault).

1. Générer un PAT depuis Snowflake UI (DATA2AI → Programmatic Access Tokens)
2. Le stocker dans `secrets/snowflake_pat.txt`
3. Le stocker dans Key Vault sous le nom `SnowflakePAT`
4. Le distribuer sur les VMs apprenants

> `[NOTE]` Le script `Set-SnowflakePATs.ps1` est archivé dans `scripts/_archive/`
> et n'est plus l'approche recommandée. Tous les apprenants utilisent le même PAT
> partagé avec isolation par `LEARNER_PREFIX` et states Terraform séparés.

---

### 21. `terraform destroy` échoue sur `00-bootstrap` avec `prevent_destroy`

**Symptôme :**

```text
Error: azurerm_storage_account.state has lifecycle.prevent_destroy set
```

**Cause :**

Le module `00-bootstrap` contient `lifecycle { prevent_destroy = true }` sur
la storage account pour empêcher la destruction accidentelle du state Terraform.

**Correction :**

Pour un cleanup intentionnel et complet uniquement :

1. Éditer `project/00-bootstrap/main.tf`
2. Changer temporairement `prevent_destroy = false`
3. Exécuter `terraform destroy -auto-approve`
4. **Restaurer immédiatement** `prevent_destroy = true`

> `[SECURITY]` Ne jamais laisser `prevent_destroy = false` en production.
> Cette opération ne doit être effectuée que pour un cleanup complet de fin
> de formation.

---

### 22. `03-devops-setup` échoue avec `AADSTS70025` ou `ForbiddenByRbac` sur le variable group

**Symptôme :**

```text
Error: Expanding variable group resource data: Failed to get the Azure Key value.
Error: ( code: badRequest, messge: Microsoft Entra rejected the token issued by
Azure DevOps with error code AADSTS70025: The client ... has no configured
federated identity credentials
```

ou :

```text
Error: ( code: forbidden, messge: Failed to query service connection API ...
Status Code: 'Forbidden', Response from server: '{"error":{"code":"Forbidden",
"message":"Caller is not authorized to perform action on resource..."}}'
```

**Cause :**

Le provider Azure DevOps crée la service connection WIF et la federated
identity credential automatiquement, mais **ne peut pas accorder le RBAC
Key Vault** au service principal ADO créé dynamiquement (son object ID
n'est pas connu à l'avance).

**Correction (Formateur) :**

```powershell
# 1. Récupérer l'appId du SP ADO depuis le message d'erreur
$spAppId = "<appId depuis l'erreur>"

# 2. Récupérer son object ID
$spObjectId = (az ad sp show --id $spAppId --query id -o tsv)

# 3. Accorder Key Vault Secrets User
az role assignment create `
  --role "Key Vault Secrets User" `
  --scope "/subscriptions/8c42d5b2-ab70-4051-ab0e-a96877557f6a/resourceGroups/rg-data2ai-tf-state/providers/Microsoft.KeyVault/vaults/kvdata2aitfsecretsmsn" `
  --assignee-object-id $spObjectId `
  --assignee-principal-type ServicePrincipal

# 4. Attendre ~30s, puis relancer
cd project/03-devops-setup
terraform plan -out devops-setup.tfplan
terraform apply devops-setup.tfplan
```

---

### 23. `Set-SnowflakePATs.ps1` échoue avec `KEY_VAULT_NAME not set`

**Symptôme :**

```text
[FAIL] KEY_VAULT_NAME not set. Pass -KeyVaultName or set in config/shared.env.
```

**Cause :**

Le script recherche `config/shared.env` à la racine du dépôt, mais le fichier
n'existe qu'à `templates/data-platform-starter/config/shared.env`.

**Correction :**

```powershell
# Copier shared.env à la racine du dépôt
Copy-Item templates/data-platform-starter/config/shared.env config/shared.env
```

> `[NOTE]` Le fichier `config/shared.env` à la racine est nécessaire pour
> que les scripts instructor puissent résoudre `KEY_VAULT_NAME` sans
> paramètre explicite. Les deux copies doivent rester synchronisées.

---

### 24. Connexion Snowflake CLI `training` pointe vers le mauvais compte

**Symptôme :**

```text
Failed to connect to DB: VYUJNGZ-DY31329.snowflakecomputing.com:443.
Your free trial has ended...
```

**Cause :**

La connexion `training` dans `~/.snowflake/config.toml` pointe vers un
ancien compte Snowflake au lieu du compte de formation actuel.

**Correction :**

Vérifier et corriger `~/.snowflake/config.toml` :

```toml
[connections.training]
account = "ZVFXOZW-PM71247"
user = "DATA2AI"
host = "ZVFXOZW-PM71247.snowflakecomputing.com"
role = "SYSADMIN"
authenticator = "PROGRAMMATIC_ACCESS_TOKEN"
token_file_path = "D:\\Data2AI Academy\\Snowflake-terraform\\secrets\\snowflake_pat.txt"
```

Tester :

```powershell
snow sql -c training -q "SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()"
```

**Expected :** `DATA2AI` / `SYSADMIN` / `HQ33884`

---

### 25. `terraform apply` échoue avec `RoleAssignmentExists` (409 Conflict)

**Symptôme :**

```text
Error: unexpected status 409 (409 Conflict) with error: RoleAssignmentExists
```

**Cause :**

Deux ressources Terraform tentent d'attribuer le même rôle au même principal
au même scope. Cela arrive quand `wif_service_principal_object_id` et
`state_blob_contributor_object_ids[0]` pointent vers le même SP.

**Correction :**

Le module `00-bootstrap` a été corrigé pour filtrer les doublons : si le SP
WIF est le même que le SP apprenant, l'attribution de rôle dupliquée est
omise. Si vous rencontrez encore cette erreur, vérifiez que vos
`terraform.tfvars` ne référencent pas le même object ID dans les deux
variables.

---

### 26. `Learner-Login.ps1` KV-first échoue : `AAD login failed or cancelled`

**Symptôme :**

```text
[INFO] KV-first mode: authenticating with your AAD account...
[WARN] AAD login failed or cancelled.
       Falling back to local secrets file.
```

**Causes possibles :**

| Cause | Correction |
|---|---|
| Navigateur annulé | Relancez le script, complétez le login dans le navigateur |
| Compte AAD non configuré | Le formateur doit créer votre compte AAD (`02-azuread-learners`) |
| Compte AAD sans accès KV | Le formateur doit accorder `Key Vault Secrets User` au groupe `Data2AI-Learners` |
| Tenant incorrect | Vérifiez que vous utilisez le compte dans le bon tenant |
| Réseau bloqué | Vérifiez la connectivité vers `login.microsoftonline.com` |

**Solution de secours :**

```powershell
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01 -ForceFallback
```

Ce mode utilise les fichiers locaux `secrets/shared-sp.txt` et `secrets/snowflake_pat.txt`.

---

### 27. `Learner-Login.ps1` KV-first : `Missing SP secrets in Key Vault`

**Symptôme :**

```text
[WARN] Missing SP secrets in Key Vault: ArmClientId, ArmClientSecret
       Falling back to local secrets file.
```

**Cause :**

Les secrets SP (`ArmClientId`, `ArmClientSecret`, `ArmTenantId`, `ArmSubscriptionId`)
ne sont pas présents dans Key Vault, ou l'apprenant n'a pas le RBAC pour les lire.

**Correction (Formateur) :**

```powershell
# Vérifier que les secrets existent
az keyvault secret list --vault-name kvdata2aitfsecretsmsn --query "[?starts_with(name,'Arm')].name" -o tsv

# Vérifier que le groupe learners a accès
az role assignment list --scope "/subscriptions/.../vaults/kvdata2aitfsecretsmsn" --query "[?roleDefinitionName=='Key Vault Secrets User']" -o table
```

Si les secrets manquent, relancez `00-bootstrap` (ils sont créés par ce module).

---

### 28. `pip install` échoue avec `error: Microsoft Visual C++ 14.0 or greater is required`

**Symptôme :**

```text
Building wheel for cffi (pyproject.toml) ... error
error: Microsoft Visual C++ 14.0 or greater is required to build a wheel.
Building wheel for pyyaml (pyproject.toml) ... error
error: Microsoft Visual C++ 14.0 or greater is required.
```

**Cause :**

Le venv Python a été créé avec **Python 3.14** (ou une version récente sans wheels pre-compilés).
Les packages comme `cffi` et `pyyaml` n'ont pas de wheels binaires pour cp314 sur Windows.
`pip` tente de compiler depuis le code source, ce qui requiert Microsoft Visual C++ Build Tools.

**Correction :**

Relancez simplement `Install-Tools.ps1` — le script :
1. installe Python 3.12 via `winget` si nécessaire ;
2. détecte que l'ancien venv utilise la mauvaise version ;
3. supprime et recrée le venv avec Python 3.12 ;
4. utilise `--prefer-binary` pour privilégier les wheels pre-compilés.

```powershell
.\scripts\Install-Tools.ps1
```

Si le problème persiste après une nouvelle exécution, supprimez manuellement le venv
et relancez :

```powershell
Remove-Item -Recurse -Force "$HOME\.data2ai\venv" -ErrorAction SilentlyContinue
.\scripts\Install-Tools.ps1
```

---

### 29. Snowflake CLI — `Installation did not complete` (Python version mismatch)

**Symptôme :**

```text
Snowflake CLI    Core       FAIL    Installation did not complete
```

ou :

```text
dbt              Course     FAIL    Installation did not complete
```

**Cause :**

Le venv a été créé avec une version de Python non compatible (ex. 3.13 ou 3.14).
Les packages Snowflake CLI et dbt-snowflake nécessitent Python 3.12.
L'installation échoue car les dépendances (cffi, pyyaml, etc.) ne peuvent pas être compilées.

**Diagnostic :**

```powershell
# Vérifier la version du venv
& "$HOME\.data2ai\venv\Scripts\python.exe" --version
```

Si le résultat n'est pas `Python 3.12.x`, le venv doit être recréé.

**Correction :**

Relancez `Install-Tools.ps1` — le script installe Python 3.12, détecte l'ancien venv
avec la mauvaise version, le supprime et le recrée correctement :

```powershell
.\scripts\Install-Tools.ps1
```

Si le problème persiste, supprimez manuellement le venv et relancez :

```powershell
Remove-Item -Recurse -Force "$HOME\.data2ai\venv" -ErrorAction SilentlyContinue
.\scripts\Install-Tools.ps1
```

Voir aussi l'entrée 28 pour les détails sur l'erreur MSVC.

---

### 30. `New-SnowflakeConnection.ps1` affiche `[WARN] .env not found`

**Symptôme :**

```text
[WARN] .env not found — using environment variables only.
```

**Cause :**

Le script `New-SnowflakeConnection.ps1` lit les paramètres de connexion depuis `.env`.
Si le fichier n'existe pas, il affiche un avertissement et tente d'utiliser les variables
d'environnement (qui sont probablement vides).

**Correction :**

Suivez l'étape 5.2 du lab pour créer `.env` :

```powershell
cp .env.example .env
# Éditez .env avec votre préfixe apprenant
```

Puis relancez :

```powershell
.\scripts\New-SnowflakeConnection.ps1
```

---

### 31. `Learner-Login.ps1` fallback échoue : `secrets/shared-sp.txt not found`

**Symptôme :**

```text
[WARN] AAD login failed or cancelled.
       Falling back to local secrets file.
[FAIL] secrets/shared-sp.txt not found.
```

**Cause :**

Le mode KV-first a échoué (compte AAD non configuré, navigateur annulé, etc.) et le
mode fallback ne trouve pas le fichier `secrets/shared-sp.txt` contenant les credentials
du service principal partagé.

**Correction :**

1. **Vérifiez que le fichier existe :**

```powershell
Test-Path secrets\shared-sp.txt
```

2. **Si absent**, demandez au formateur le fichier `secrets/shared-sp.txt`.
   Ce fichier contient les credentials du service principal partagé :

```text
ARM_CLIENT_ID=...
ARM_TENANT_ID=...
ARM_SUBSCRIPTION_ID=...
ARM_CLIENT_SECRET=...
```

3. **Si le fichier est présent mais le login échoue encore**, vérifiez que le secret
   n'a pas expiré (voir entrée 18).

4. **Préférez le mode KV-first** si votre compte AAD est configuré :

```powershell
.\scripts\Learner-Login.ps1 -LearnerPrefix APP01
```

> `[SECURITY]` Le fichier `secrets/shared-sp.txt` est gitignored. Ne le commitez jamais.

---

Si aucun diagnostic ne resout le probleme :

1. capturez l'erreur exacte (sans secret);
2. notez votre systeme et votre repertoire courant;
3. transmettez au formateur.
