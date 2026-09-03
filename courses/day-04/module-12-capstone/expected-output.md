# Résultat attendu — M12 : Capstone

> [<- Jour 4](../README.md) · [<- Module precedent](../module-11-rbac/lab.md) · **Module 12** · [Module suivant ->](../module-13-finops-observability/lab.md)

## Plan de la plateforme complète
```bash
cd project/05-capstone/environments/dev
terraform init
terraform plan
```
**Nombre de ressources attendu :** 20+ ressources réparties sur :
- Landing zone (bases, warehouses, schémas, tags, monitors)
- RBAC (rôles, grants, future grants)
- File formats
- Network policy
- Utilisateur de service avec clé RSA
- Data Mesh spokes (si configurés)

## Apply
```bash
terraform apply -auto-approve
```
**Attendu :** `Apply complete! Resources: N added, 0 changed, 0 destroyed.`

## Vérification zero-drift
```bash
terraform plan -detailed-exitcode
```
**Attendu :** Code de sortie 0 (`No changes.`)

## Preuves d'architecture
```sql
SHOW DATABASES;
SHOW WAREHOUSES;
SHOW ROLES LIKE 'RL_%_DEV';
SHOW RESOURCE MONITORS;
SHOW INTEGRATIONS;
SHOW NETWORK POLICIES;
```
**Attendu :** Tous les objets de la plateforme présents et correctement nommés avec le suffixe `_DEV`.

## Checklist de démonstration d'équipe
- [ ] Landing zone : 2 bases, 2+ warehouses, 3 schémas, tags, monitor
- [ ] RBAC : 6 rôles, hiérarchie, future grants
- [ ] Sécurité : network policy, utilisateur de service avec clé RSA
- [ ] Zero drift : `terraform plan` ne montre aucun changement
- [ ] Naming : tous les objets suivent la convention `ENV_TEAM_ROLE`

## Extensions (optionnelles)
- **Lab M13 — FinOps :** `dbt build` dans `finops/`
- **Lab M14 — Data Products :** `snow sql` via Snow CLI

