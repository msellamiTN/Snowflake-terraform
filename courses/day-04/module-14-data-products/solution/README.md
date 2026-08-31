# Solution M14

La solution exécutable est `project/06-data-products/` :

- `environments/dev` et `environments/test` instancient le Golden Path ;
- `project/03-day2-modules/modules/data-product` implémente le contrat réutilisable ;
- `sql/sales` et `sql/finance` illustrent la publication Snow CLI.

La solution attend un warehouse `WH_ETL_{ENV}` déjà fourni par la Landing Zone. Après l'apply, publiez le SQL puis vérifiez que Terraform reste zero-drift.

