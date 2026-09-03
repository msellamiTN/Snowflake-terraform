# Solution de référence — M3 : Import & Brownfield

## Source

| Technique | Source |
|-----------|--------|
| `terraform import` | Sur la database `DB_<PREFIX>_BROWNFIELD_DEV` créée manuellement au début du lab |
| Blocs `moved {}` | Ajoutés à `main.tf` pendant le lab |
| `terraform state mv` | Commandes de manipulation du state (alternative au bloc `moved`) |

## Contrat technique

| Élément | Valeur attendue |
|---|---|
| Dossier de travail | `environments/dev/` |
| Ressource brownfield | `snowflake_database.brownfield` → importée depuis `DB_<PREFIX>_BROWNFIELD_DEV` |
| Génération de config | `terraform plan -generate-config-out=generated.tf` |
| Bloc moved | `snowflake_database.brownfield` → `snowflake_database.imported` |
| Plan final | `No changes` |

## Résultat attendu

- L'objet importé apparaît dans le state
- La config générée correspond à l'objet importé
- Le bloc `moved` renomme l'adresse de la ressource sans destruction
- `terraform plan` ne montre aucun changement après refactor

## Checklist formateur

- [ ] Le préflight vérifie Terraform `v1.14.5` et `No changes` sur le state M2
- [ ] La database `DB_<PREFIX>_BROWNFIELD_DEV` est créée manuellement hors Terraform (préfixe par apprenant)
- [ ] L'import utilise le bon nom de database
- [ ] `generated.tf` est intégré dans `main.tf` puis supprimé
- [ ] La dérive est détectée par `plan` puis corrigée par `apply`
- [ ] Le bloc `moved` déplace la ressource sans destruction
- [ ] Aucun state, plan ou secret n'est suivi par Git
