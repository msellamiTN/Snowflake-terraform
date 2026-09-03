# Module 00 — Préparer l’environnement

**Durée : 1 h 45**

**Résultat final : `Ready for Day 1`**

## Commencer

Ouvrez d’abord le point d’entrée unique :

[`courses/day-00/README.md`](../../courses/day-00/README.md)

Il vous guidera dans cet ordre :

1. choisir Windows, Linux ou macOS;
2. installer/vérifier Git, Terraform et Snowflake CLI;
3. choisir Sandbox ou Trial;
4. protéger la configuration locale;
5. configurer la connexion Snowflake;
6. exécuter le préflight;
7. créer ce workspace et produire le rapport.

## Créer le workspace

Exécutez ces commandes uniquement lorsque le guide Day 0 vous le demande.

### Windows

```powershell
.\scripts\New-StudentWorkspace.ps1 -Module 0 -Initials ABC
.\scripts\SelfPacedLab.ps1 -Module 0 -All -Report
```

### Linux/macOS

```bash
bash ./scripts/new-student-workspace.sh --module 0 --initials ABC
bash ./scripts/self-paced-lab.sh --module 0 --all --report
```

Remplacez `ABC` par deux à quatre lettres majuscules.

## Terminé lorsque

- [ ] le préflight affiche `Ready for Day 1`;
- [ ] le validateur M00 ne contient aucun `FAIL`;
- [ ] aucun secret n’apparaît dans Git;
- [ ] votre workspace se trouve sous `$HOME/Data2AI-Labs`.

En cas d'erreur, utilisez le [troubleshooting Day 0](../../courses/day-00/module-00-setup/troubleshooting.md) et rejouez uniquement le dernier checkpoint.
