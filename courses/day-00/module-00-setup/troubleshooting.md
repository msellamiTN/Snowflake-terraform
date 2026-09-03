# Jour 0 — Guide de troubleshooting

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

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

## Escalade

Si aucun diagnostic ne resout le probleme :

1. capturez l'erreur exacte (sans secret);
2. notez votre systeme et votre repertoire courant;
3. transmettez au formateur.
