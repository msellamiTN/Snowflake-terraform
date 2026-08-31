# Jour 0 — Guide de troubleshooting

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Symptômes et diagnostics

### 1. `terraform : command not found` après l'installation

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

Vérifiez que `$HOME\.data2ai\bin` est présent. Sinon, relancez le script d'installation.

**Linux/macOS :**

Ajoutez à votre profil shell (`~/.bashrc` ou `~/.zshrc`) :

```bash
export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"
```

Puis :

```bash
source ~/.bashrc
```

---

### 2. `snow : command not found` après l'installation

**Diagnostic :**

Snow CLI est installé dans l'environnement virtuel Python.

```bash
# Windows
$HOME\.data2ai\venv\Scripts\snow.exe --version

# Linux/macOS
$HOME/.data2ai/venv/bin/snow --version
```

**Si la commande fonctionne avec le chemin complet :**

Ajoutez le dossier `Scripts` ou `bin` du venv au PATH (voir symptôme 1).

---

### 3. `dbt : command not found`

Même cause que `snow`. dbt est installé dans le même environnement virtuel.

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

- Python 3.12 n'est pas installé et une autre version est trouvée;
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

### 5. `snow connection add` échoue

**Diagnostic :**

```bash
snow connection list
```

**Causes possibles et corrections :**

| Cause | Correction |
|---|---|
| PAT expiré | Demander un nouveau PAT au formateur |
| Compte incorrect | Vérifier l'identifiant de compte fourni |
| Organisation incorrecte | Vérifier l'identifiant d'organisation |
| Utilisateur incorrect | Vérifier le nom d'utilisateur |
| Réseau bloqué | Vérifier la connectivité vers Snowflake |

**Test de connectivité :**

```bash
# Windows
Test-NetConnection -ComputerName <account>.snowflakecomputing.com -Port 443

# Linux/macOS
nc -zv <account>.snowflakecomputing.com 443
```

---

### 6. `snow sql` échoue avec une erreur de permission

**Symptôme :**

```text
Insufficient privileges for operation
```

**Diagnostic :**

Le rôle utilisé n'a pas les privilèges nécessaires.

**Correction :**

Vérifiez le rôle attribué lors de la création de la connexion. Pour la formation, `SYSADMIN` est le rôle attendu. N'utilisez pas `ACCOUNTADMIN` sauf instruction explicite du formateur.

```bash
snow sql -q 'SELECT CURRENT_ROLE()' -c training
```

---

### 7. `git clone` échoue

**Causes possibles :**

| Cause | Correction |
|---|---|
| URL incorrecte | Vérifier l'URL fournie par le formateur |
| Authentification requise | Le dépôt template est privé : configurer l'accès Git |
| Réseau bloqué | Vérifier la connectivité vers la plateforme Git |

**Test :**

```bash
git ls-remote <TEMPLATE_REPO_URL>
```

---

### 8. Le rapport contient un `FAIL` pour un outil

**Procédure :**

1. Lire la ligne `Action` dans le rapport — elle contient la procédure manuelle.
2. Suivre la procédure manuelle officielle.
3. Relancer le mode `Check` :

```bash
# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check

# Linux/macOS
./scripts/install-tools.sh --check
```

4. Si l'outil passe en `PASS`, continuer. Sinon, demander l'aide du formateur.

---

### 9. Une politique d'entreprise bloque l'installation

**Symptôme :**

Le script affiche `FAIL` et la procédure manuelle, mais l'installation manuelle est également bloquée.

**Diagnostic :**

Le poste est géré par une politique d'entreprise qui interdit l'installation de logiciels.

**Correction :**

Demandez au formateur ou à l'administrateur du poste d'installer les outils manquants avec la procédure officielle de l'entreprise. Le script d'installation ne contourne jamais une politique de sécurité.

---

### 10. Le PATH est modifié mais ne persiste pas

**Windows :**

Le script modifie le PATH utilisateur, qui persiste entre les sessions. Si le PATH ne persiste pas, vérifiez que vous avez les droits pour modifier les variables d'environnement utilisateur.

**Linux/macOS :**

Le script ne modifie pas automatiquement le profil shell. Ajoutez manuellement :

```bash
echo 'export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Escalade

Si aucun diagnostic ne résout le problème :

1. capturez l'erreur exacte (sans secret);
2. notez votre système et votre répertoire courant;
3. transmettez au formateur.
