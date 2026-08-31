# Solution de référence — M8 : Stratégies d'environnements

## Source

| Fichier | Chemin source |
|---------|---------------|
| Racine DEV | `project/03-day2-modules/environments/dev/` |
| Racine TEST | `project/03-day2-modules/environments/test/` |
| Backend DEV | `project/03-day2-modules/environments/dev/backend.tf.example` |
| Backend TEST | `project/03-day2-modules/environments/test/backend.tf.example` |

## Résultat attendu

- DEV et TEST ont des clés de state séparées
- Les ressources sont nommées avec les suffixes `_DEV` et `_TEST`
- Aucun partage de ressources cross-environnement
- PROD est en plan-only en formation

