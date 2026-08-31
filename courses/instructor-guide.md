# Guide formateur — Terraform & Snowflake

**Durée officielle : 5 jours × 6 heures — 30 heures**  
**Modalité :** instructor-led ou accompagnement d’un parcours self-paced  
**Programme maître :** [`PROGRAMME_FORMATION.md`](../PROGRAMME_FORMATION.md)

## 1. Responsabilité du formateur

Le formateur garantit un environnement prévisible, des identités isolées, des coûts bornés et une voie de récupération. Il ne remplace pas la pratique par une démonstration longue et ne distribue pas la solution complète pour résoudre une erreur locale.

Objectif de répartition :

- 10 à 15 % d’orientation et démonstration;
- 65 à 70 % de pratique;
- 10 à 15 % de débrief et évaluation;
- 10 % de marge de remédiation intégrée aux séquences.

## 2. Préparation obligatoire

### J-10 à J-5

- [ ] choisir le scénario principal : sandbox fournie ou Trial personnel;
- [ ] confirmer Windows/PowerShell et Linux/macOS/Bash pour chaque participant;
- [ ] publier les versions testées des outils;
- [ ] vérifier accès réseau au registre Terraform et à Snowflake;
- [ ] attribuer un préfixe unique à chaque apprenant;
- [ ] définir quota, date d’expiration et procédure de cleanup;
- [ ] tester le parcours complet avec un compte sans privilèges implicites.

### J-2

- [ ] exécuter le préflight sur une machine Windows propre;
- [ ] exécuter le préflight sur une machine Unix propre;
- [ ] tester au moins une identité sandbox et un compte Trial;
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

## 3. Deux scénarios d’accès

### Scénario A — Sandbox préprovisionnée

Le formateur fournit hors Git :

- organization/account Snowflake;
- utilisateur ou mécanisme d’identification individuel;
- PAT temporaire;
- préfixe unique de ressources;
- rôle initial et limites;
- date d’expiration;
- canal de support et procédure de reset.

Le bootstrap administratif doit être réalisé avant la formation. `ACCOUNTADMIN` ne doit pas devenir le rôle quotidien de l’apprenant.

### Scénario B — Trial personnel

Le formateur vérifie que l’apprenant :

- a accès à son compte et connaît sa région;
- peut ouvrir Snowsight et une worksheet;
- peut créer une identité technique ou appliquer la procédure de secours;
- active des garde-fous de consommation;
- comprend ce qui restera après le cours et comment le supprimer.

Le formateur ne collecte jamais le mot de passe, le PAT ou la clé privée d’un participant.

## 4. Politique d’authentification

| Usage | Méthode | Règle |
|---|---|---|
| Démarrage sandbox | PAT temporaire | distribué hors Git, expiration courte |
| Démarrage Trial | PAT | créé par l’apprenant et stocké localement |
| Cible production | JWT key-pair | identité technique, rotation et stockage sécurisé |
| Bootstrap exceptionnel | rôle élevé | durée minimale et action explicitement délimitée |

Une valeur secrète n’est jamais affichée sur projection, collée dans un ticket ou incluse dans un rapport de validation.

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
| 1 h 00 | Séparation en pistes sandbox/Trial, puis checkpoint commun |
| 2 h 15 | Live coding très court, puis création autonome fichier par fichier |
| 0 h 45 | Lecture du plan, apply, preuve Snowflake et idempotence |
| 0 h 15 | Quiz et cleanup |

### Jour 2 — State et changement

| Durée | Animation |
|---:|---|
| 0 h 45 | Inspection du state et limites de sécurité |
| 1 h 00 | Variables, locals et conventions |
| 1 h 00 | `for_each`, dépendances et lifecycle |
| 1 h 15 | Import brownfield et refactoring sûr |
| 0 h 45 | Drift contrôlé et remédiation |
| 0 h 45 | Contrat backend + pistes Cloud optionnelles |
| 0 h 30 | Challenge et debrief |

### Jour 3 — Modules et environnements

| Durée | Animation |
|---:|---|
| 0 h 45 | Atelier de définition du contrat |
| 2 h 00 | Construction du module Landing Zone |
| 0 h 45 | Collections et couches de données |
| 1 h 00 | Isolation DEV/TEST |
| 0 h 45 | Qualité, documentation et versioning |
| 0 h 45 | Challenge d’extension |

### Jour 4 — Sécurité et RBAC

| Durée | Animation |
|---:|---|
| 0 h 45 | Modèle de privilèges |
| 1 h 30 | RBAC as Code |
| 1 h 00 | Grants et tests positifs/négatifs |
| 0 h 45 | PAT/JWT et rotation |
| 0 h 45 | Ingestion interne et variantes Cloud |
| 0 h 45 | Incidents contrôlés |
| 0 h 30 | Challenge moindre privilège |

### Jour 5 — Industrialisation et capstone

| Durée | Animation |
|---:|---|
| 0 h 45 | Pipeline portable |
| 0 h 45 | GitHub Actions et mapping Azure DevOps |
| 0 h 45 | FinOps/dbt |
| 0 h 45 | Data Products |
| 2 h 15 | Capstone autonome; aide graduée uniquement |
| 0 h 45 | Soutenance, score, zero-drift et cleanup |

## 7. Checkpoints de promotion

| Passage | Condition |
|---|---|
| Day 0 → J1 | rapport `Ready for Day 1`, connexion Snowflake valide |
| J1 → J2 | premier projet appliqué, vérifié, puis second plan stable |
| J2 → J3 | state cohérent, import et drift validés |
| J3 → J4 | module Landing Zone et environnements isolés |
| J4 → J5 | RBAC vérifié, secrets absents de Git |
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
- ne pas donner `ACCOUNTADMIN` comme correction générique;
- ne pas remplacer le workspace apprenant par la solution finale.

## 10. Coûts et cleanup

- annoncer les ressources facturables avant création;
- utiliser tailles minimales et auto-suspend;
- vérifier les préfixes individuels;
- effectuer un cleanup quotidien des ressources non réutilisées;
- conserver uniquement les ressources explicitement requises le lendemain;
- confirmer le résultat avec Terraform et Snowflake;
- pour les pistes Azure/AWS/GCP, vérifier également le fournisseur Cloud.

## 11. Matériel formateur

- programme maître et catalogue;
- slides et diagrammes rendus;
- solution de référence testée;
- snapshots de récupération par checkpoint;
- matrice objectifs/activités/preuves;
- liste des versions testées;
- incidents connus et procédures de reprise;
- rubric du capstone;
- procédure de cleanup sandbox/Trial;
- attribution et droits des logos officiels utilisés.

## 12. Definition of Done avant publication

- [ ] 30 heures chronométrées en dry run;
- [ ] sandbox et Trial testés;
- [ ] PowerShell et Bash testés;
- [ ] chaque lab part d’un workspace propre;
- [ ] chaque objectif a une preuve;
- [ ] chaque panne documentée a été reproduite et corrigée;
- [ ] liens et diagrammes valides;
- [ ] starters sans secrets ni artefacts Terraform téléchargés;
- [ ] solutions formatées, validées, appliquées, idempotentes et nettoyables;
- [ ] capstone réalisable sans lire la solution;
- [ ] licences des logos vérifiées.
