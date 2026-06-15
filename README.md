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
flutter build apk --release   # APK signé → build/app/outputs/flutter-apk/app-release.apk
```

## Configuration Google Cloud (projet `goldinvoicesapp`)

La sauvegarde Drive nécessite les éléments suivants configurés dans [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=goldinvoicesapp) :

| Élément | Valeur |
|---------|--------|
| Client Android (type 1) | `833854972385-1pq3th38qkft9lnm5o2jjvif7g3jktuv.apps.googleusercontent.com` |
| Client Web Application (type 3) | `833854972385-n4p30ffkidfgnhut5de9nm63u0a5n01o.apps.googleusercontent.com` |
| Package Android | `com.kemogoha.goldinvoices` |
| Debug SHA-1 | `6B:8A:62:24:A8:A7:D3:E0:91:9C:30:36:0C:7D:EE:59:28:EB:65:E0` |
| Release SHA-1 | `56:C5:0C:9E:AF:AD:48:3E:61:35:45:DD:44:82:51:C8:3B:D2:3C:E9` |
| Scope Drive | `drive.file` (non-sensible) |
| Écran de consentement | **En production** — tout compte Google peut autoriser, sans liste d'utilisateurs test |

Les deux SHA-1 (debug + release) sont enregistrés sur le client Android (type 1).

Pour obtenir le SHA-1 d'un keystore :
```bash
# debug
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
# release
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

### Build de release (signing)

`android/app/build.gradle.kts` charge `android/key.properties` (gitignoré) pour la config de signature `release`, avec repli sur les clés debug si absent. Le keystore `android/app/upload-keystore.jks` et `key.properties` sont **gitignorés — ne jamais les committer**. Perdre le keystore = impossible de mettre à jour l'app.

`key.properties` attendu :
```properties
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=upload-keystore.jks
```

`drive.file` étant un scope non-sensible, la publication en production ne requiert **aucune vérification Google**. L'avertissement "branding doit être validé" est cosmétique et ne bloque pas l'autorisation.

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
