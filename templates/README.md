# Publication du dépôt template

Ce dossier contient le squelette de gouvernance `data-platform-starter`. Il est conçu pour être publié comme un dépôt Git séparé que les apprenants clonent au Day 0.

## Procédure de publication

### 1. Créer le dépôt distant

Sur votre plateforme Git (GitHub, Azure DevOps ou GitLab), créez un nouveau dépôt public ou privé nommé `data-platform-starter`.

### 2. Initialiser le dépôt local

```bash
cd templates/data-platform-starter
git init
git add .
git commit -m "Initial governance scaffold for data-platform-starter"
```

### 3. Pousser le squelette

```bash
git remote add origin <VOTRE_URL_DEPOT>
git branch -M main
git push -u origin main
```

### 4. Configurer la variable d'environnement

Dans le fichier `.env.example` du dépôt de formation, renseignez :

```text
TEMPLATE_REPO_URL=https://github.com/msellamiTN/data-platform-starter.git
```

Les ateliers Day 0 utilisent cette variable pour cloner le projet type.

### 5. Vérifier

- le clonage du dépôt produit l'arborescence décrite dans `data-platform-starter/README.md`;
- aucun fichier `.tf` de ressource n'est présent;
- `terraform fmt -check` et `tflint` passent sur le squelette;
- le pipeline `azure-pipelines.yml` est syntaxiquement valide.

## Mise à jour

Toute modification du squelette doit être faite dans ce dossier `templates/` puis reportée dans le dépôt publié. Les apprenants clonent la version publiée, pas ce dossier directement.
