# Guide formateur — Terraform & Snowflake

**Durée officielle : 5 jours × 6 heures — 30 heures**

**Modalité :** instructor-led ou accompagnement d’un parcours self-paced

**Stack :** Snowflake Enterprise, Terraform, Azure, Azure DevOps, dbt

**Références :** [programme](../PROGRAMME_FORMATION.md) · [architecture](../docs/reference-architecture.md) · [versions](../docs/version-policy.md)

## 1. Responsabilité du formateur

Le formateur garantit un environnement prévisible, des identités isolées, des coûts bornés et une voie de récupération. Il ne remplace pas la pratique par une démonstration longue et ne distribue pas la solution complète pour résoudre une erreur locale.

Objectif de répartition :

- 10 à 15 % d’orientation et démonstration;
- 65 à 70 % de pratique;
- 10 à 15 % de débrief et évaluation;
- 10 % de marge de remédiation intégrée aux séquences.

## 2. Préparation obligatoire

### J-10 à J-5

- [ ] confirmer les accès Snowflake, Azure et Azure DevOps de chaque participant;
- [ ] attribuer un préfixe unique à chaque apprenant et publier la liste;
- [ ] confirmer Windows/PowerShell et Linux/macOS/Bash pour chaque poste;
- [ ] publier la [politique de versions](../docs/version-policy.md);
- [ ] vérifier l’accès réseau au registre Terraform, à Snowflake et à Azure;
- [ ] définir quotas, budgets, dates d’expiration et procédure de cleanup;
- [ ] réaliser le bootstrap administratif Snowflake;
- [ ] tester le parcours avec un compte sans privilèges implicites.

### J-2

- [ ] exécuter le préflight sur une machine Windows propre;
- [ ] exécuter le préflight sur une machine Unix propre;
- [ ] vérifier qu’un `terraform init` résout exactement les versions publiées;
- [ ] tester le pool d’agents Azure DevOps et la connexion de service;
- [ ] tester l’approbation du stage `Apply`;
- [ ] exécuter `dbt deps` et `dbt build` sur le projet FinOps;
- [ ] vérifier que les starters ne contiennent ni secret, state, plan, `.terraform/` ni provider binaire;
- [ ] exécuter les validateurs de chaque module;
- [ ] reproduire les incidents prévus dans `troubleshooting.md`;
- [ ] vérifier toutes les sorties attendues susceptibles de varier selon les versions.

### Avant chaque journée

- [ ] vérifier le checkpoint final de la journée précédente;
- [ ] confirmer les ressources qui doivent encore exister;
- [ ] confirmer les ressources à nettoyer;
- [ ] préparer un snapshot de récupération séparé de la solution apprenant;
- [ ] annoncer la durée, les pauses, les preuves attendues et le challenge.

## 3. Accès à provisionner

La formation s’exécute sur l’environnement d’entreprise : compte Snowflake Enterprise unique, Azure et Azure DevOps.

### Snowflake

Le formateur fournit hors Git, pour chaque participant :

- organization et account;
- utilisateur ou mécanisme d’identification individuel;
- **préfixe apprenant unique** de 2 à 12 caractères;
- PAT temporaire à expiration courte;
- rôle initial suffisant pour DEV, sans droits sur PROD;
- date d’expiration et procédure de reset.

Le bootstrap administratif est réalisé **avant** la formation. Aucun rôle d’administration ne devient le rôle quotidien de l’apprenant.

### Azure

- souscription ou groupe de ressources dédié à la formation;
- droits de création : compte de stockage, Key Vault, intégration;
- quota et budget avec alerte;
- convention de nommage des ressources de formation.

### Azure DevOps

- projet de formation avec dépôt;
- variable groups préparés, valeurs saisies par le formateur;
- connexion de service Azure par fédération d’identité;
- pool d’agents disponible et testé;
- environnement avec approbation configurée pour le stage `Apply`.

## 4. Politique d’authentification

| Étape | Méthode | Règle |
|---|---|---|
| Day 0 à Jour 3 | PAT temporaire via profil Snowflake CLI | distribué hors Git, expiration courte |
| Jour 4 | Identité technique et JWT key-pair | clé privée stockée dans Key Vault |
| Pipeline | Fédération d’identité Azure | aucun secret client stocké |
| Bootstrap exceptionnel | rôle élevé | durée minimale, action délimitée, tracée |

Une valeur secrète n’est jamais affichée sur projection, collée dans un ticket, ni incluse dans un rapport de validation. Le formateur ne collecte jamais le PAT ou la clé privée d’un participant.

## 5. Conduite d’un module

1. **Orienter** — présenter la tâche professionnelle et la preuve finale.
2. **Préflight** — vérifier le répertoire, le shell, l’identité et les prérequis.
3. **Faire créer** — laisser l’apprenant créer dossier, fichier et bloc de code.
4. **Expliquer** — relier chaque nouveau bloc à l’architecture.
5. **Valider** — exécuter le checkpoint immédiatement.
6. **Faire diagnostiquer** — utiliser le symptôme exact et une commande non destructive.
7. **Consolider** — proposer un exercice avec moins d’indices.
8. **Évaluer** — challenge et preuve, sans révéler la solution.
9. **Nettoyer** — confirmer la portée, exécuter, puis vérifier.

### Règle d’aide graduée

1. demander le message d’erreur exact;
2. confirmer le répertoire et le shell;
3. faire exécuter le diagnostic du lab;
4. donner un indice conceptuel;
5. montrer la différence attendue sur quelques lignes;
6. restaurer le dernier checkpoint;
7. consulter la solution complète uniquement en dernier recours.

## 6. Planning formateur

### Jour 1 — Préparer, créer et déployer

| Durée | Animation |
|---:|---|
| 0 h 45 | Contrat du cours, architecture, sécurité, coûts et cleanup |
| 1 h 00 | Préflight accompagné Windows/Unix |
| 1 h 00 | Distribution des accès, profil PAT et préfixe apprenant |
| 2 h 15 | Live coding très court, puis création autonome fichier par fichier |
| 0 h 45 | Lecture du plan, apply, preuve Snowflake et idempotence |
| 0 h 15 | Quiz et cleanup |

### Jour 2 — State et changement

| Durée | Animation |
|---:|---|
| 0 h 45 | Inspection du state et limites de sécurité |
| 1 h 15 | Backend Azure Blob : création, migration, verrouillage |
| 1 h 00 | Variables, locals et conventions DEV/UAT/PROD |
| 1 h 00 | `for_each`, dépendances et lifecycle |
| 1 h 15 | Import brownfield et dérive contrôlée |
| 0 h 45 | Challenge et debrief |

### Jour 3 — Modules et environnements

| Durée | Animation |
|---:|---|
| 0 h 45 | Atelier de définition du contrat |
| 2 h 00 | Construction du module Landing Zone |
| 0 h 45 | Collections et couches RAW/CLEAN/CURATED |
| 1 h 15 | Isolation DEV/UAT et promotion vers PROD |
| 0 h 45 | Qualité, documentation et versioning |
| 0 h 30 | Challenge d’extension |

### Jour 4 — Sécurité et RBAC

| Durée | Animation |
|---:|---|
| 0 h 45 | Modèle de privilèges |
| 1 h 30 | RBAC as Code |
| 0 h 45 | Grants et tests positifs/négatifs |
| 1 h 00 | Identité technique, JWT et Key Vault |
| 0 h 45 | Ingestion Azure Data Lake Storage |
| 0 h 45 | Incidents contrôlés |
| 0 h 30 | Challenge moindre privilège |

### Jour 5 — Industrialisation et capstone

| Durée | Animation |
|---:|---|
| 1 h 00 | Pipeline Azure DevOps de bout en bout |
| 0 h 30 | Policy as Code et quality gates |
| 0 h 45 | FinOps/dbt |
| 0 h 45 | Data Products |
| 2 h 15 | Capstone autonome; aide graduée uniquement |
| 0 h 45 | Soutenance, score, zero-drift et cleanup |

## 7. Checkpoints de promotion

| Passage | Condition |
|---|---|
| Day 0 → J1 | rapport `Ready for Day 1`, connexion Snowflake valide |
| J1 → J2 | premier projet appliqué, vérifié, puis second plan stable |
| J2 → J3 | state migré vers Azure Blob, import et dérive validés |
| J3 → J4 | module Landing Zone et environnements DEV/UAT isolés |
| J4 → J5 | RBAC vérifié, clé dans Key Vault, secrets absents de Git |
| Fin | capstone ≥ 75 %, cleanup ou justification documentée |

Un apprenant bloqué utilise le checkpoint de récupération; il ne copie pas le dossier `project/`.

## 8. Évaluation

| Élément | Poids |
|---|---:|
| Checkpoints automatisés | 30 % |
| Preuves fonctionnelles | 25 % |
| Challenges quotidiens | 20 % |
| Capstone et soutenance | 25 % |

Les preuves peuvent inclure : rapport du validateur, sortie `terraform plan`, requête Snowflake, test dbt et diagramme expliqué. Toute preuve doit être expurgée de secrets et d’identifiants sensibles.

## 9. Gestion des incidents

### Triage en moins de cinq minutes

1. relever commande, répertoire, shell et erreur exacte;
2. exécuter une commande de diagnostic non destructive;
3. classer l’incident : outil, chemin, syntaxe, authentification, privilège, état, réseau ou quota;
4. appliquer la correction minimale;
5. rejouer le checkpoint, pas tout le lab;
6. consigner une amélioration si le support n’avait pas anticipé l’incident.

### Interdictions

- ne pas demander un secret dans le chat ou par capture;
- ne pas désactiver un contrôle de sécurité pour gagner du temps;
- ne pas supprimer un state ou des ressources sans portée et confirmation;
- ne pas donner un rôle d’administration comme correction générique;
- ne pas remplacer le workspace apprenant par la solution finale.

## 10. Coûts et cleanup

### Snowflake

- annoncer les ressources facturables avant création;
- imposer `X-SMALL`, `auto_suspend` court et `initially_suspended`;
- vérifier les préfixes individuels;
- suspendre les warehouses en fin de journée;
- supprimer les objets non réutilisés le lendemain.

### Azure

- vérifier le groupe de ressources de formation;
- arrêter ou désallouer les agents hors session;
- contrôler la croissance du compte de stockage de state;
- conserver Key Vault jusqu’à la fin de la formation, puis suivre la procédure de suppression;
- confirmer le budget et les alertes après chaque journée.

Le cleanup est confirmé dans les **deux** environnements avant de clore une journée.

## 11. Matériel formateur

- programme maître, catalogue et architecture de référence;
- politique de versions;
- runbook d’animation minuté;
- solution de référence testée;
- snapshots de récupération par checkpoint;
- matrice objectifs/activités/preuves;
- pipeline Azure DevOps et variable groups documentés;
- incidents connus et procédures de reprise;
- rubric du capstone;
- procédures de cleanup Snowflake et Azure.

## 12. Definition of Done avant publication

- [ ] 30 heures chronométrées en dry run;
- [ ] accès Snowflake, Azure et Azure DevOps testés;
- [ ] PowerShell et Bash testés;
- [ ] versions conformes à la politique de versions;
- [ ] DEV, UAT et PROD cohérents dans le code et les supports;
- [ ] pipeline Azure DevOps exécuté au moins une fois;
- [ ] `dbt deps` et `dbt build` réussis;
- [ ] chaque lab part d’un workspace propre;
- [ ] chaque objectif a une preuve;
- [ ] chaque panne documentée a été reproduite et corrigée;
- [ ] liens et diagrammes valides;
- [ ] starters sans secrets ni artefacts Terraform téléchargés;
- [ ] aucun identifiant de compte réel dans les supports;
- [ ] capstone réalisable sans lire la solution.
