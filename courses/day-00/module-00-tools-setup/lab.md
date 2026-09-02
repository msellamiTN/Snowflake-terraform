# 🧪 Étape 1 — Installer et vérifier les outils (scripts d'abord)

**Durée cible : 40 minutes**

**Retour au parcours :** [Jour 0 — Commencer ici](../README.md)

## Résultat attendu

À la fin de cette étape, le rapport de la chaîne d'outils affiche :

```text
Toolchain status: READY
```

et tous les outils **Core** sont en `PASS`.

## Approche

Le Jour 0 est **automatisé**. Vous clonez d'abord le projet type, puis vous exécutez les scripts qui se trouvent **dans le clone**. Ensuite, vous lisez le rapport et comprenez ce qui a été fait.

- **Windows** : `scripts/Install-Tools.ps1`
- **Linux/macOS** : `scripts/install-tools.sh`

Les deux scripts ont le même contrat : mêmes versions, mêmes vérifications, même format de rapport.

---

## 1. Cloner le projet type

Le projet type est le dépôt `data-platform-starter`. Il contient les scripts d'installation, la structure de gouvernance et les validateurs. **C'est votre racine de travail pour toute la formation.**

### 1.1 — Cloner le projet type

Le dépôt du projet type est : `https://github.com/msellamiTN/data-platform-starter.git`

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
New-Item -ItemType Directory -Path "$HOME\Data2AI-Labs" -Force | Out-Null
git clone https://github.com/msellamiTN/data-platform-starter.git "$HOME\Data2AI-Labs\data-platform"
cd "$HOME\Data2AI-Labs\data-platform"
```
</details>

> ⚠️ **IMPORTANT** Sous Windows, ne pas utiliser `~` (tilde) dans le chemin de clone.
> PowerShell ne l'interprète pas comme le dossier personnel. Utilisez `$HOME` entre guillemets.
> Si le répertoire contient des espaces (ex. `Formation Terraform`), encadrez le chemin :
> ```powershell
> git clone https://github.com/msellamiTN/data-platform-starter.git "$HOME\Data2AI-Labs\data-platform"
> ```

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
mkdir -p "$HOME/Data2AI-Labs"
git clone https://github.com/msellamiTN/data-platform-starter.git "$HOME/Data2AI-Labs/data-platform"
cd "$HOME/Data2AI-Labs/data-platform"
```
</details>

### 1.3 — Vérifier que les scripts sont présents

```bash
ls scripts/
```

✅ **Checkpoint** :

```text
Install-Tools.ps1
install-tools.sh
New-SnowflakeConnection.ps1
new-snowflake-connection.sh
validate.ps1
validate.sh
```

> À partir d'ici, **toutes les commandes s'exécutent depuis la racine du clone** (`$HOME/Data2AI-Labs/data-platform`).

---

## Piste Windows

### 2W.1 — Ouvrir PowerShell

Ouvrez PowerShell 5.1 ou 7 dans le dossier du clone. Vous n'avez pas besoin de privilèges administrateur : les outils sont installés sous votre profil utilisateur.

### 2W.2 — Diagnostic initial

Exécutez le script en mode `Check` pour voir l'état actuel sans rien installer :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check -ReportPath .\preflight
```

✅ **Checkpoint** : un rapport s'affiche et deux fichiers sont créés (`preflight.md` et `preflight.json`). Les outils déjà installés sont en `PASS`, les autres en `FAIL` ou `WARN`.

### 2W.3 — Installation

Exécutez le script en mode installation :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -ReportPath .\preflight
```

✅ **Checkpoint** : le script installe les outils manquants sous `$HOME\.data2ai`. Les outils Python (Snow CLI, dbt) sont installés dans un environnement virtuel isolé. Le rapport final indique `Toolchain status: READY`.

### 2W.4 — Corriger les échecs

Si un outil est en `FAIL`, le rapport affiche la procédure manuelle officielle. Suivez-la, puis relancez le script :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-Tools.ps1 -Check
```

### 2W.5 — Rouvrir le terminal

Si une commande reste introuvable après l'installation, fermez et rouvrez PowerShell pour rafraîchir le `PATH`.

---

## Piste Linux / macOS

### 2U.1 — Ouvrir un terminal

Ouvrez Bash dans le dossier du clone. Vous n'avez pas besoin de `sudo` : les outils sont installés sous `$HOME/.data2ai`.

### 2U.2 — Diagnostic initial

```bash
chmod +x scripts/install-tools.sh
./scripts/install-tools.sh --check --report-path ./preflight
```

✅ **Checkpoint** : un rapport s'affiche et deux fichiers sont créés (`preflight.md` et `preflight.json`).

### 2U.3 — Installation

```bash
./scripts/install-tools.sh --report-path ./preflight
```

✅ **Checkpoint** : le script installe les outils manquants. Terraform et tflint sont téléchargés sous `$HOME/.data2ai/bin`. Les outils Python sont installés dans un environnement virtuel isolé sous `$HOME/.data2ai/venv`.

### 2U.4 — Corriger les échecs

Si un outil est en `FAIL`, le rapport affiche la procédure manuelle. Suivez-la, puis relancez :

```bash
./scripts/install-tools.sh --check
```

### 2U.5 — Rouvrir le terminal

Si une commande reste introuvable, ouvrez un nouveau terminal ou exécutez :

```bash
export PATH="$HOME/.data2ai/bin:$HOME/.data2ai/venv/bin:$PATH"
```

---

## Vérification commune

### 3.1 — Vérifier les versions

<details>
<summary>🪟 <b>Windows (PowerShell)</b></summary>

```powershell
terraform version
snow --version
az version
python --version
dbt --version
```
</details>

<details>
<summary>🐧 <b>Linux/macOS (Bash)</b></summary>

```bash
terraform version
snow --version
az version
python3 --version
dbt --version
```
</details>

✅ **Checkpoint** : chaque commande retourne une version. Les versions doivent correspondre à la [politique de versions](../../docs/version-policy.md).

### 3.2 — Lire le rapport

Ouvrez `preflight.md` et vérifiez :

- [ ] tous les outils **Core** sont en `PASS`;
- [ ] les outils **Course** (Azure CLI, dbt) sont en `PASS` ou documentés comme manquants;
- [ ] aucune valeur secrète n'apparaît dans le rapport;
- [ ] le statut final est `READY`.

### 3.3 — Comprendre ce que le script a fait

Répondez à ces questions pour valider votre compréhension :

1. **Où sont installés Terraform et tflint ?**
   - Windows : `$HOME\.data2ai\bin`
   - Linux/macOS : `$HOME/.data2ai/bin`

2. **Où sont installés Snow CLI et dbt ?**
   - Dans un environnement virtuel Python isolé sous `$HOME/.data2ai/venv`.

3. **Comment le PATH a-t-il été modifié ?**
   - Windows : le dossier `$HOME\.data2ai\bin` a été ajouté au PATH utilisateur.
   - Linux/macOS : le script affiche l'instruction `export PATH=...` à ajouter à votre profil shell.

4. **Pourquoi un environnement virtuel isolé ?**
   - Pour éviter les conflits avec d'autres projets Python sur votre poste et garantir des versions reproductibles.

5. **Que faire si une politique d'entreprise bloque l'installation ?**
   - Le script affiche la procédure manuelle officielle. Suivez-la, puis relancez le mode `Check`.

---

## Checkpoint

✅ **Checkpoint** : Le rapport affiche `Toolchain status: READY` et tous les outils Core sont en `PASS`.

Si ce checkpoint passe, passez à l'[étape suivante](../module-00-day0-setup/lab.md) : configurer la connexion Snowflake.
