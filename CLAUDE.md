# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app for managing gold bar sale invoices. Single operator, single-user, **offline-first**. Replaces a desktop application the client is used to — the UI must be dense, tabular, and faithful to the original (FR number formatting). Light/dark/system theme is user-toggleable and persisted; the dark palette is the default reference.

Targets Android **and web/PWA** (the client installs the PWA on an iPhone via Safari → Share → Add to Home Screen). The backup pipeline is platform-agnostic (no `dart:io` — see Web/PWA section).

**Current state:** Google Drive backup fully implemented and tested on physical device. `schemaVersion = 2`. The single-screen entry + history-drawer UX is **implemented** (commit "single-screen entry UX") — `AppShell` + `InvoiceEntryScreen` + `InvoiceHistoryScreen` + `InvoiceDetailScreen` (read-only). The legacy 3-screen flow (List → Form → Detail) and its viewmodels are gone.

## Commands

```bash
flutter pub get                          # install deps
flutter run                              # run app (fully offline)
flutter test                             # all tests
flutter test test/domain/services/gold_bar_calculator_service_test.dart   # single test file
flutter test --plain-name "line 1"       # single test by name
flutter analyze                          # lint
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift + freezed code (after table/entity changes)
flutter build apk --release              # signed release APK → build/app/outputs/flutter-apk/app-release.apk
flutter run -d chrome                    # run the web/PWA build
flutter build web                        # web build → build/web/ (serve over HTTPS)
```

**Release signing:** `android/app/build.gradle.kts` loads `android/key.properties` (gitignored) for the `release` signing config, falling back to debug keys when absent (so `flutter run --release` still works without the keystore). Keystore `android/app/upload-keystore.jks` and `key.properties` are gitignored — never commit them. Losing the keystore means the app can no longer be updated.

## Tech Stack

- State management: `provider` (ChangeNotifier + ChangeNotifierProvider)
- Local DB: `drift` (SQLite) — **single source of truth**; `schemaVersion = 2`
- Cloud backup: Google Drive via `google_sign_in` v7 + `googleapis`; scope `drive.file`
- PDF/print: `pdf` + `printing` packages
- Routing: GoRouter; DI via Provider tree in `app/di.dart`
- FR number formatting: `intl`
- `connectivity_plus` — pre-backup connectivity check only
- `shared_preferences` — stores `last_backup_at` timestamp + `theme_mode` choice
- `flutter_native_splash` + `flutter_launcher_icons` — generate splash screen and app icon (config in `pubspec.yaml`)

## Architecture — Strict MVVM, feature-first

```
lib/
├── core/
│   ├── constants/   # app_colors.dart, app_config.dart, business_constants.dart, prefs_keys.dart
│   ├── errors/      # business_exceptions.dart, backup_exceptions.dart
│   ├── theme/       # app_theme.dart — light + dark ThemeData
│   └── utils/       # number_formatter.dart, responsive.dart
├── data/
│   ├── local/       # drift database, DAOs (InvoiceDao, InvoiceLineDao), table defs
│   ├── remote/
│   │   └── google_drive/   # GoogleDriveService, DriveBackupFile
│   ├── repositories/       # InvoiceRepositoryImpl, invoice_mappers.dart
│   └── services/           # ExportService, ImportService (Drift persistence orchestration)
├── domain/
│   ├── entities/    # Invoice, InvoiceLine, InvoiceLinePreview (pure Dart, freezed)
│   ├── repositories/# IInvoiceRepository (abstract interface)
│   └── services/    # GoldBarCalculatorService, PrintService, BackupService
├── features/
│   ├── invoice/     # viewmodels / views / widgets
│   ├── backup/      # BackupViewModel, BackupScreen
│   └── settings/    # ThemeViewModel, ThemeToggleButton
└── app/             # app.dart, app_shell.dart, router.dart, di.dart
```

Layering rules (non-negotiable):
1. No logic in widgets — all logic in ViewModels
2. ViewModels never touch Drift directly — always through repository interfaces
3. No `BuildContext` in services or repositories
4. Strong types everywhere — never pass `Map<String, dynamic>` where an entity fits
5. Every formula in `GoldBarCalculatorService` gets a doc-comment with the math written out
6. Batch calculations over 50 lines go through `compute()` / Isolate

### Provider scoping

`di.dart` (`buildProviders()`) provides everything globally — order matters, each entry may `read` the ones above it:
- `ThemeViewModel` (`..init()` called at creation) — read by `GoldBarApp` to drive `MaterialApp.themeMode`
- `AppDatabase`, `GoldBarCalculatorService`, `PrintService`
- `IInvoiceRepository` (impl: `InvoiceRepositoryImpl`)
- `ExportService`, `ImportService`, `GoogleDriveService`, `BackupService`
- `BackupViewModel` (`..init()` called at creation)
- `InvoiceEntryViewModel` — global; shared by the AppBar `BackupStatusDot` and the entry-screen body (single-user, one live draft)
- `InvoiceHistoryViewModel` — global; shared across `/history` list and `/history/:id` detail so the loaded selection survives navigation

## UX Navigation (current)

```
/ → AppShell  (AppBar: BackupStatusDot + Drawer button; body: InvoiceEntryScreen)
  ├── [Drawer] → /history     (InvoiceHistoryScreen — read-only list of saved invoices)
  │                └── tile tap → /history/:id (InvoiceDetailScreen — read-only + Reprint)
  └── [Drawer] → /backup      (BackupScreen)
```

- `InvoiceEntryScreen` is the home screen: base-price input, gross+water entry, live preview, line table, Save & Print — all driven by the global `InvoiceEntryViewModel`. Base price persists across "Ajouter barre"; only gross/water clear (then focus returns to gross). After "Enregistrer & Imprimer" everything clears for the next invoice.
- `BackupReminderBanner` sits above the entry form; `BackupStatusDot` (colored circle) lives in the AppBar.
- `InvoiceDetailScreen` is read-only (saved invoices only) with a Reprint action — it no longer handles draft editing.

## Business Domain — Calculation Formulas (CRITICAL)

Encapsulated in `GoldBarCalculatorService`, unit tested against real capture data. One invoice line = one gold bar, weighed by the hydrostatic (Archimedes) method.

| Domain (FR) | Code name     | Meaning                                                  |
|-------------|---------------|----------------------------------------------------------|
| Poids brut  | `grossWeight` | weight in air (grams)                                    |
| Eaux        | `waterWeight` | weight submerged in water                                |
| Densité     | `density`     | grossWeight / waterWeight                                |
| Carat       | `carat`       | purity (shown in red in UI and PDF)                      |
| U/BASE      | `unitPrice`   | price per gram for this bar                              |
| Montant     | `amount`      | line total                                               |
| Base        | `basePrice`   | market reference price, same for all lines of an invoice |

The 4 formulas, applied in order:

```dart
density   = truncate2(grossWeight / waterWeight);
carat     = float32(truncate2((density - 10.51) * 52.838 / density));  // A=10.51 alloy density, B=52.838
unitPrice = (basePrice / 22) * carat;            // full double
amount    = round2(unitPrice * grossWeight);     // rounded to cents at calc time
```

**Two fidelity rules — both required to reproduce the desktop TO THE CENT** (all five reference lines + total below match exactly; verified by the unit tests):

1. **Truncation, not rounding**, on density and carat. `truncate2(x) = (x*100).truncateToDouble()/100`. 30.22/1.63 → raw density 18.53988 must become 18.53 (not 18.54); raw carat 22.8688 → 22.86 (not 22.87).
2. **Carat is cast to 32-bit float** after truncation (`float32(x)` via `Float32List`). The old desktop app held carat in a single-precision `float`, so 22.32 is really `22.31999969…`. That tiny deviation, carried into a `double` unitPrice × gross and rounded to cents, is what produces the desktop amounts. Pure-`double` carat is off by up to 0.42/line, 0.50 on the total — close but not faithful. The float32 carat displays as "22.32" because `NumberFormatter.carat()` rounds.

`unitPrice` keeps full double precision (it is the operand of the amount product); `amount` is `round2`-ed at calc time (not just display) so summed line totals reproduce the desktop total exactly.

Verification data (basePrice = 70200) — unit tests must match these exactly:

```
Line 1: gross=430.87, water=23.67 → density=18.20, carat=22.32, unitPrice=71221.09, amount=30 687 031.02
Line 2: gross=126.39, water=6.87  → carat=22.64, amount=9 130 689.11
Line 3: gross=73.18,  water=3.98  → carat=22.62, amount=5 282 012.85
Line 4: gross=37.69,  water=2.06  → carat=22.47, amount=2 702 362.64
Line 5: gross=30.22,  water=1.63  → carat=22.86, amount=2 204 373.23
Totals: grossWeight=698.35, waterWeight=38.21, amount=50 006 468.85
```

All calculations use `double` — never `int` for monetary values. Display rounded to 2 decimals. Calculated values (density, carat, unitPrice, amount) are **stored** in `invoice_lines`, not recomputed on read.

## Invoice Lifecycle — Draft Safety

`InvoiceStatus` enum: `draft` | `saved`. Stored as text in `invoices.status`.

- `InvoiceEntryViewModel.addLine()` lazily calls `_repo.createDraft()` on the first bar → INSERT with `status = 'draft'` (survives app kill)
- Each line added → INSERT line + UPDATE invoice totals (barCount, totalGrossWeight, totalWaterWeight, totalAmount) atomically in one transaction
- `saveAndPrint()` → `finalizeInvoice()` → status → `saved`, generate PDF, open `Printing.layoutPdf()` native sheet; then `autoBackupIfConnected()` fire-and-forget; then `_resetForNewInvoice()`
- App reopen: `_loadExistingDraft()` rehydrates any open draft into the entry screen. Only one draft at a time — `createDraft()` throws `InvoiceStateException` if one exists

Invoice number format: `FAC-XXXX` (e.g. `FAC-0001`), sequential across all invoices (not year-scoped). Generated via `maxId()` + 1 at draft creation time.

Only `saved` invoices are ever exported or backed up.

## Google Drive Backup Architecture

Three-layer backup flow:

```
BackupViewModel → BackupService → ExportService / ImportService / GoogleDriveService
```

- **ExportService** (`data/services/`): queries all saved invoices + lines from Drift, serializes to JSON, returns a `BackupPayload {fileName, json}` value object — **no file I/O, no `dart:io`** (works on web). Filename `gold_invoices_backup_YYYY-MM-DD_HHmmss.json`
- **ImportService** (`data/services/`): `importFromJson(String content)` — validates `schemaVersion`, runs a single Drift transaction (DELETE saved → INSERT from backup; drafts untouched). Takes a JSON string, not a `File`.
- **GoogleDriveService** (`data/remote/google_drive/`): `google_sign_in` v7 + `googleapis`; scope `drive.file` (app-created files only); folder `GoldInvoicesApp/backups/`. `uploadBackup(String fileName, List<int> bytes)`; `downloadBackup(id)` returns the JSON content as a `String` (no temp file). `DriveBackupFile` is a typed value object for listing results.
- **BackupService** (`domain/services/`): orchestrates the above; owns `autoBackupIfConnected()` (fire-and-forget, never throws to caller). Checks `isAuthorizedSilently()` before upload to avoid background sign-in dialogs.

### Auto-backup triggers (all wired)
1. After every `saveAndPrint()` in `InvoiceEntryViewModel` — fire-and-forget via `autoBackupIfConnected()`
2. At app startup — only if last backup > 24 h ago and a backup has been done before (`_StartupController` in `app.dart`)
3. `BackupReminderBanner` on `InvoiceEntryScreen` if last backup > 3 days ago (or never backed up)

`PrefsKeys.lastBackupAt` (ISO 8601 UTC string in SharedPreferences) tracks the last successful backup.

### Backup JSON format
```json
{
  "exportedAt": "ISO8601",
  "appVersion": "1.0.0",
  "schemaVersion": 2,
  "invoices": [...],
  "invoiceLines": [...]
}
```
All `DateTime` as ISO 8601 UTC; all `double` at full precision. Drafts excluded.

### Typed exceptions (in `core/errors/backup_exceptions.dart`)
- `SchemaVersionMismatchException` — backup schema ≠ current app schema
- `CorruptedBackupException` — JSON parse failure

### Google Cloud Console configuration (projet `goldinvoicesapp`, numéro `833854972385`)

| Élément | Valeur |
|---------|--------|
| Package Android | `com.kemogoha.goldinvoices` |
| Debug SHA-1 | `6B:8A:62:24:A8:A7:D3:E0:91:9C:30:36:0C:7D:EE:59:28:EB:65:E0` |
| Release SHA-1 | `56:C5:0C:9E:AF:AD:48:3E:61:35:45:DD:44:82:51:C8:3B:D2:3C:E9` |
| Client Android (type 1) | `833854972385-1pq3th38qkft9lnm5o2jjvif7g3jktuv.apps.googleusercontent.com` — **les deux** SHA-1 (debug + release) y sont enregistrés |
| Client Web Application (type 3) | `833854972385-n4p30ffkidfgnhut5de9nm63u0a5n01o.apps.googleusercontent.com` |
| `serverClientId` (constante `AppConfig.googleServerClientId`) | client Web ci-dessus |
| Scope Drive | `drive.file` (fichiers créés par l'app uniquement, non-sensible) |
| Écran de consentement | **En production** (publié) — tout compte Google peut autoriser, pas de liste d'utilisateurs test, token sans expiration |

**Publication OAuth :** `drive.file` étant non-sensible, la publication en production ne demande **aucune vérification Google**. L'avertissement "branding doit être validé" est cosmétique (logo/nom) et ne bloque **pas** l'autorisation.

**Symptôme connu — la sauvegarde tourne à l'infini après le sélecteur de compte :** `authorizationHeaders(promptIfNecessary: true)` ne retourne jamais (aucune exception). Cause = compte non autorisé pour l'état de l'écran de consentement (app en mode Test + compte absent des utilisateurs test). Fix = publier en production, ou ajouter le compte aux utilisateurs test.

**Fichiers Android concernés:**
- `android/app/google-services.json` — contient les deux clients OAuth (type 1 + type 3)
- `android/app/src/main/kotlin/com/kemogoha/goldinvoices/MainActivity.kt` — package corrigé
- `main.dart` — `GoogleSignIn.instance.initialize(serverClientId: AppConfig.googleServerClientId)` appelé avant `runApp` (constante dans `core/constants/app_config.dart`)
- `lib/data/remote/google_drive/google_drive_service.dart` — `_ensureInitialized()` ne **rappelle pas** `initialize()` (déjà fait une seule fois dans `main.dart` avec les bons args plateforme). Un second appel jette sur web `Bad state: init() has already been called`. Il se contente de `attemptLightweightAuthentication()` pour restaurer une session existante. (`initialize()` doit donc rester correct dans `main.dart` : `clientId` sur web, `serverClientId` sur Android.)

## Web / PWA

The app builds for web (`flutter build web` → `build/web/`) and installs as a PWA on the client's iPhone (Safari → Share → Add to Home Screen). Required runtime files live in `web/`:
- `web/sqlite3.wasm` + `web/drift_worker.js` — Drift loads SQLite as WebAssembly in the browser. `AppDatabase._openConnection()` **must** pass `web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js'))` to `driftDatabase()`; omitting it throws at runtime `Invalid argument(s): When compiling to the web, the 'web' parameter needs to be set` (the option is ignored on native). The URIs resolve against the page base href, so the two files must sit at the web root. Versions track `drift` 2.34.0 / `sqlite3` (dart) 3.3.3 — re-download from the matching GitHub releases (`simolus3/drift` for the worker, `simolus3/sqlite3.dart` for the wasm) if those bump.
- `web/index.html` — meta `google-signin-client_id` (web OAuth client), iOS PWA tags (`apple-mobile-web-app-capable`, title "Gold Invoices").

Web-specific behavior (see the google_sign_in gotchas below): platform-split `initialize()` and `_resolveHeaders` use `kIsWeb`. The whole backup pipeline (Export/Import/Drive) passes `String`/bytes, never `dart:io` `File`, so it compiles and runs on web unchanged.

⚠️ For web sign-in to work: in Google Cloud Console, the **Web** client (type 3) must list the serving domain under **Authorized JavaScript origins** (`https://…` in prod, `http://localhost:PORT` to test), and the app must be served over HTTPS (PWA install + OAuth require it; `localhost` excepted). In iOS standalone mode the Google OAuth popup can misbehave — validate on the real device.

## UI Conventions

- Dark palette in `core/constants/app_colors.dart`: background `0xFF1A1A2E`, table bg `0xFF16213E`, header `0xFF0F3460`, carat accent red `0xFFE94560`, border `0xFF2D3561`
- Theme: light + dark `ThemeData` in `core/theme/app_theme.dart`; `ThemeViewModel` (`features/settings/`) holds `ThemeMode` (light/dark/system), persisted under `PrefsKeys.themeMode`. `ThemeToggleButton` toggles it. `GoldBarApp` reads the VM for `MaterialApp.themeMode`
- **Carat column always red** (`AppColors.accentCarat`); Base column dimmed (`AppColors.textMuted`)
- Numbers: use `NumberFormatter` named methods — `amount()`, `weight()`, `carat()`, `density()`, `unitPrice()`, `date()`. Do NOT call a generic `.format()` — no such method exists. Internally strips intl's U+202F narrow no-break space (fr_FR grouping) because PDF base fonts can't encode it.
- Responsive: `core/utils/responsive.dart` — mobile < 600 px gets horizontally scrollable table, tablet ≥ 600 px gets full-width table
- Invoice header: `Bamako le: [date]` + `Nombre Barres: [n]` — location (default `'Bamako'`) and issueDate editable while drafting; barCount is computed
- PDF (PrintService): landscape, `pw.TableBorder` grid, carat column in `PdfColors.red`, same FR formatting as UI

## Implementation Gotchas

- Drift row classes renamed via `@DataClassName` (`InvoiceRow`, `InvoiceLineRow`) to avoid clashing with domain entities; mapping in `data/repositories/invoice_mappers.dart`
- `invoice_lines.invoiceId` has `onDelete: KeyAction.cascade` + `PRAGMA foreign_keys = ON` in `beforeOpen` — discarding a draft deletes its lines automatically
- `basePrice` is locked once an invoice has lines (`updateDraftHeader` throws) — stored line amounts would diverge from the header
- `AppDatabase.forTesting(NativeDatabase.memory())` constructor used in all Drift tests — no file I/O needed
- ViewModels subscribe to Drift streams in their constructor (`_repo.watchX().listen(...)`) and cancel in `dispose()` — never use `StreamBuilder` in views, drive UI from ViewModel state
- `google_sign_in` v7 API: `GoogleSignIn.instance.initialize()` called once in `main.dart` (before `runApp`); authorization via `authorizationClient.authorizationHeaders(_scopes, promptIfNecessary: bool)` — no `GoogleSignIn(scopes: [...])` constructor style. **Platform-split init** (both `main.dart` and `GoogleDriveService._ensureInitialized` must match): web passes `clientId: AppConfig.googleWebClientId`, Android passes `serverClientId: AppConfig.googleServerClientId` — guarded by `kIsWeb`. Passing `serverClientId` on web is unsupported; omitting `serverClientId` on Android throws "serverClientId must be provided on Android".
- **Web has no interactive `authenticate()`** — `_resolveHeaders` branches on `kIsWeb`: web calls `authorizationClient.authorizeScopes(_scopes)` (must be triggered by a user gesture / button tap) then re-reads headers silently; Android keeps the `authenticate(scopeHint:) → authorizationHeaders(promptIfNecessary: true)` flow.
- `InvoiceRepositoryImpl` receives both `AppDatabase` and `GoldBarCalculatorService` — it calls the calculator internally so DAOs stay pure data-access
- Comma input (`replaceAll(',', '.')`) needed before `double.tryParse()` for FR locale keyboards

## Out of Scope

No customer/client entity, no authentication, no multi-user, no sync conflict resolution, no push notifications for backup reminders.

## UX Architecture (single-screen entry — implemented)

The legacy 3-screen flow (List → Form → Detail) was replaced by:
- **`AppShell`** (`app/app_shell.dart`) — root `Scaffold` wrapping `InvoiceEntryScreen`, with `AppDrawer` (Drawer nav) and `BackupStatusDot` in the AppBar
- **`InvoiceEntryScreen`** — single home screen: base price input, poids+eaux entry card, real-time preview, line table, Save & Print
- **`InvoiceHistoryScreen`** — from Drawer; read-only list of saved invoices
- **`InvoiceDetailScreen`** — read-only detail + Reprint; never edits drafts

ViewModels (both global in `di.dart`):
- `InvoiceEntryViewModel` — `basePrice`, `grossWeight`, `waterWeight`, live preview (`currentPreview`), draft lifecycle (`addLine()` lazily creates the draft, `saveAndPrint()`, `_loadExistingDraft()`, `_resetForNewInvoice()`), `canAddLine`, `canSaveAndPrint`, `isSavingAndPrinting`, `shouldShowBackupReminder`/`backupReminderMessage`/`refreshBackupStatus()`
- `InvoiceHistoryViewModel` — watches saved invoices, loads selected invoice + lines for detail, `reprintInvoice()`

Key UX behaviors of `InvoiceEntryScreen`:
- Base price persists across "Ajouter barre" — only gross/water fields clear, then focus returns to gross
- Preview shows `—` placeholders when inputs are empty/invalid
- After "Enregistrer & Imprimer": all fields clear, table empties, ready for the next invoice immediately
- `BackupReminderBanner` above the entry form; `BackupStatusDot` (colored circle) in the AppBar
