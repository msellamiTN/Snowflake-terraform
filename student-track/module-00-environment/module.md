# Module 00 — Préparer l’environnement

**Durée :** 1 h 45  
**Résultat :** rapport `Ready for Day 1`  
**Guide complet :** [`courses/day-00/module-00-day0-setup/lab.md`](../../courses/day-00/module-00-day0-setup/lab.md)

## Démarrage

### Windows

```powershell
.\scripts\New-StudentWorkspace.ps1 -Module 0 -Initials ABC
.\scripts\SelfPacedLab.ps1 -Module 0 -All -Report
```

### Linux/macOS

```bash
./scripts/new-student-workspace.sh --module 0 --initials ABC
./scripts/self-paced-lab.sh --module 0 --all --report
```

Remplacez `ABC` par deux à quatre lettres majuscules. La validation ne lit ni n’affiche la valeur d’un PAT ou d’une clé privée.
