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

- Python 3.12 n'est pas installe et une autre version est trouvee;
- plusieurs versions de Python coexistent et la mauvaise est prioritaire.

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

## Escalade

Si aucun diagnostic ne resout le probleme :

1. capturez l'erreur exacte (sans secret);
2. notez votre systeme et votre repertoire courant;
3. transmettez au formateur.
