# Résultat attendu — M3 : Import & Brownfield

## Préflight

```bash
cd environments/dev
terraform state list
terraform plan
```

**Attendu :** Les ressources M1 sont listées (database, schemas, warehouse) et `terraform plan` affiche `No changes`.

## Création de la ressource brownfield

```bash
snow sql -c training -q "SHOW DATABASES LIKE 'BROWNFIELD_DEV'"
```

**Attendu :** une ligne avec la database `BROWNFIELD_DEV`.

## Import

```bash
terraform import snowflake_database.brownfield BROWNFIELD_DEV
```

**Attendu :**

```text
Import successful!
```

## State après import

```bash
terraform state list
```

**Attendu :** la liste contient `snowflake_database.brownfield` en plus des ressources M1.

## Génération de config

```bash
terraform plan -generate-config-out=generated.tf
```

**Attendu :** un fichier `generated.tf` est créé avec les attributs de la database.

Après intégration dans `main.tf` et suppression de `generated.tf` :

```bash
terraform plan
```

**Attendu :**

```text
No changes. Your infrastructure matches the configuration.
```

## Détection de dérive

Après `ALTER DATABASE BROWNFIELD_DEV SET COMMENT = 'Modified outside Terraform'` :

```bash
terraform plan
```

**Attendu :** Terraform détecte que le `comment` a changé et propose de le remettre à `Created manually outside Terraform`.

## Correction de dérive

```bash
terraform apply
```

**Attendu :** Terraform remet le `comment` à la valeur de la configuration. Plan suivant : `No changes.`

## Bloc moved

Après avoir renommé `snowflake_database.brownfield` en `snowflake_database.imported` avec un bloc `moved` :

```bash
terraform plan
```

**Attendu :**

```text
1 resource has been moved.
No changes. Your infrastructure matches the configuration.
```

Après suppression du bloc `moved` :

```bash
terraform plan
```

**Attendu :** `No changes.`
