# Gold Bar Invoice Management

Application Flutter mobile de gestion de factures de vente de lingots d'or. Mode hors-ligne, mono-utilisateur, avec sauvegarde Google Drive.

## Fonctionnalités

- Création et gestion de factures (FAC-XXXX)
- Saisie de barres d'or pesées par méthode hydrostatique (Archimède)
- Calcul automatique : densité, carat, prix unitaire, montant
- Impression PDF (paysage A4, formatage FR)
- Sauvegarde/restauration sur Google Drive
- Bannière de rappel si dernière sauvegarde > 3 jours
- Sauvegarde automatique silencieuse après chaque impression et au démarrage

## Stack technique

| Couche | Technologie |
|--------|-------------|
| State management | `provider` (ChangeNotifier) |
| Base de données locale | `drift` (SQLite), schemaVersion=2 |
| Cloud backup | Google Drive (`google_sign_in` v7 + `googleapis`) |
| PDF | `pdf` + `printing` |
| Routing | `go_router` |
| Formatage nombres | `intl` (locale fr_FR) |

## Architecture

MVVM strict, feature-first :

```
lib/
├── core/           # constantes, thème, erreurs, utils
├── data/
│   ├── local/      # Drift DB, DAOs, modèles de tables
│   ├── remote/     # google_drive/GoogleDriveService
│   ├── repositories/
│   └── services/   # ExportService, ImportService (orchestration Drift)
├── domain/
│   ├── entities/   # Invoice, InvoiceLine (freezed)
│   ├── repositories/
│   └── services/   # GoldBarCalculatorService, PrintService, BackupService
├── features/
│   ├── invoice/    # viewmodels / views / widgets
│   └── backup/     # BackupViewModel, BackupScreen
└── app/            # app.dart, app_shell.dart, router.dart, di.dart
```

### Navigation

```
/ → AppShell (InvoiceEntryScreen)  — saisie sur écran unique : prix de base,
    barre (poids + eaux), aperçu temps réel, tableau, Enregistrer & Imprimer
  ├── Drawer → /history       — liste lecture seule des factures sauvegardées
  │              └── /history/:id — détail lecture seule + Réimprimer
  └── Drawer → /backup        — gestion Google Drive
```

## Commandes

```bash
flutter pub get
flutter run
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

## Configuration Google Cloud (projet `goldinvoicesapp`)

La sauvegarde Drive nécessite les éléments suivants configurés dans [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=goldinvoicesapp) :

| Élément | Valeur |
|---------|--------|
| Client Android (type 1) | `833854972385-1pq3th38qkft9lnm5o2jjvif7g3jktuv.apps.googleusercontent.com` |
| Client Web Application (type 3) | `833854972385-n4p30ffkidfgnhut5de9nm63u0a5n01o.apps.googleusercontent.com` |
| Package Android | `com.kemogoha.goldinvoices` |
| Debug SHA-1 | `6B:8A:62:24:A8:A7:D3:E0:91:9C:30:36:0C:7D:EE:59:28:EB:65:E0` |
| Scope Drive | `drive.file` |
| Écran de consentement | Mode Test — ajouter les utilisateurs dans "Utilisateurs test" |

Pour obtenir le SHA-1 du keystore de debug :
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

### Ajouter un utilisateur test

Google Cloud Console → APIs & Services → Écran de consentement OAuth → Utilisateurs test → + Add users.

### Pour un build de release

1. Générer un keystore de release et enregistrer son SHA-1 comme nouveau client Android dans Cloud Console
2. Mettre à jour `android/app/google-services.json` avec le nouveau client
3. Soumettre l'écran de consentement OAuth pour vérification Google

## Formules de calcul (critiques)

```
density   = truncate2(grossWeight / waterWeight)
carat     = truncate2((density - 10.51) * 52.838 / density)
unitPrice = (basePrice / 22) * carat
amount    = unitPrice * grossWeight
```

**Troncature obligatoire** (pas d'arrondi) : `truncate2(x) = (x*100).truncateToDouble()/100`

## Cycle de vie d'une facture

`draft` → (Save & Print) → `saved`

- Un seul brouillon à la fois
- Chaque barre ajoutée : INSERT ligne + UPDATE totaux en une transaction
- Abandon brouillon : cascade delete des lignes (FK)
- Numérotation : `FAC-XXXX` séquentiel
