# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter mobile app for managing gold bar sale invoices. Single operator, single-user, **offline-first**. Replaces a desktop application the client is used to — the UI must be dense, tabular, and faithful to the original (dark theme, FR number formatting).

**Current state:** Google Drive backup fully implemented and tested on physical device. `schemaVersion = 2`. New UX phase (single-screen entry + history drawer) is the next step — see [New UX Phase](#new-ux-phase).

## Commands

```bash
flutter pub get                          # install deps
flutter run                              # run app (fully offline)
flutter test                             # all tests
flutter test test/domain/services/gold_bar_calculator_service_test.dart   # single test file
flutter test --plain-name "line 1"       # single test by name
flutter analyze                          # lint
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift + freezed code (after table/entity changes)
```

## Tech Stack

- State management: `provider` (ChangeNotifier + ChangeNotifierProvider)
- Local DB: `drift` (SQLite) — **single source of truth**; `schemaVersion = 2`
- Cloud backup: Google Drive via `google_sign_in` v7 + `googleapis`; scope `drive.file`
- PDF/print: `pdf` + `printing` packages
- Routing: GoRouter; DI via Provider tree in `app/di.dart`
- FR number formatting: `intl`
- `connectivity_plus` — pre-backup connectivity check only
- `shared_preferences` — stores `last_backup_at` timestamp

## Architecture — Strict MVVM, feature-first

```
lib/
├── core/
│   ├── constants/   # app_colors.dart, business_constants.dart, prefs_keys.dart
│   ├── errors/      # business_exceptions.dart, backup_exceptions.dart
│   ├── theme/
│   └── utils/       # number_formatter.dart, responsive.dart
├── data/
│   ├── local/       # drift database, DAOs (InvoiceDao, InvoiceLineDao), table defs
│   ├── remote/
│   │   └── google_drive/   # GoogleDriveService, DriveBackupFile
│   └── repositories/       # InvoiceRepositoryImpl, invoice_mappers.dart
├── domain/
│   ├── entities/    # Invoice, InvoiceLine, InvoiceLinePreview (pure Dart, freezed)
│   ├── repositories/# IInvoiceRepository (abstract interface)
│   └── services/    # GoldBarCalculatorService, PrintService, ExportService,
│                    # ImportService, BackupService
├── features/
│   ├── invoice/     # viewmodels / views / widgets
│   └── backup/      # BackupViewModel, BackupScreen
└── app/             # app.dart, router.dart, di.dart
```

Layering rules (non-negotiable):
1. No logic in widgets — all logic in ViewModels
2. ViewModels never touch Drift directly — always through repository interfaces
3. No `BuildContext` in services or repositories
4. Strong types everywhere — never pass `Map<String, dynamic>` where an entity fits
5. Every formula in `GoldBarCalculatorService` gets a doc-comment with the math written out
6. Batch calculations over 50 lines go through `compute()` / Isolate

### Provider scoping

`di.dart` provides globally (available to entire app):
- `AppDatabase`, `GoldBarCalculatorService`, `PrintService`
- `IInvoiceRepository` (impl: `InvoiceRepositoryImpl`)
- `ExportService`, `ImportService`, `GoogleDriveService`, `BackupService`
- `BackupViewModel` (global — `..init()` called at creation)

Created locally via `ChangeNotifierProvider` inside each screen:
- `InvoiceListViewModel` — created in `InvoiceListScreen.build()`
- `InvoiceFormViewModel` — created in `InvoiceFormScreen.build()`
- `InvoiceDetailViewModel` — created in `InvoiceDetailScreen.build()`, takes `invoiceId`

## UX Navigation (current)

```
/ (InvoiceListScreen)
  ├── [FAB] → /invoices/new (InvoiceFormScreen)
  │             sets location, issueDate, basePrice → creates draft → pushReplacement
  │             ↓
  │           /invoices/:id (InvoiceDetailScreen)  ← add bars via bottom sheet, Save & Print
  └── [DraftBanner resume] → /invoices/:id (same draft)
  └── [list tile tap] → /invoices/:id (read-only saved invoice)
  └── [AppBar icon] → /backup (BackupScreen)
```

- `InvoiceDetailScreen`: "Ajouter Barre" FAB opens `showInvoiceLineFormSheet()` (modal bottom sheet with real-time preview); reads `invoice.isDraft` to toggle FAB and delete-line actions
- `InvoiceFormScreen` navigates to detail via `pushReplacement` so "back" returns to list

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
carat     = truncate2((density - 10.51) * 52.838 / density);  // A=10.51 alloy density, B=52.838
unitPrice = (basePrice / 22) * carat;
amount    = unitPrice * grossWeight;
```

**Truncation is mandatory, not rounding.** `truncate2(x) = (x*100).truncateToDouble()/100`. Without it the verification data below is NOT reproducible: 30.22/1.63 gives raw density 18.53988 → must become 18.53 (not 18.54), raw carat 22.8849 → expected 22.86 (truncated from 22.8688 computed on truncated density). unitPrice and amount keep full double precision; rounding only at display.

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

- `InvoiceFormScreen` → `_repo.createDraft()` → INSERT with `status = 'draft'` (survives app kill)
- Each line added → INSERT line + UPDATE invoice totals (barCount, totalGrossWeight, totalWaterWeight, totalAmount) atomically in one transaction
- "Save & Print" → `finalizeInvoice()` → status → `saved`, generate PDF, open `Printing.layoutPdf()` native sheet; then `_backupService?.autoBackupIfConnected()` fire-and-forget
- App reopen: `watchDraft()` → show `DraftBanner` (Resume / Discard). Discard cascade-deletes lines via FK.
- Only one draft at a time — `createDraft()` throws `InvoiceStateException` if one exists

Invoice number format: `FAC-XXXX` (e.g. `FAC-0001`), sequential across all invoices (not year-scoped). Generated via `maxId()` + 1 at draft creation time.

Only `saved` invoices are ever exported or backed up.

## Google Drive Backup Architecture

Three-layer backup flow:

```
BackupViewModel → BackupService → ExportService / ImportService / GoogleDriveService
```

- **ExportService** (`domain/services/`): queries all saved invoices + lines from Drift, serializes to JSON, writes temp file `gold_invoices_backup_YYYY-MM-DD_HHmmss.json`
- **ImportService** (`domain/services/`): reads JSON, validates `schemaVersion`, runs a single Drift transaction (DELETE saved → INSERT from backup; drafts untouched)
- **GoogleDriveService** (`data/remote/google_drive/`): `google_sign_in` v7 + `googleapis`; scope `drive.file` (app-created files only); folder `GoldInvoicesApp/backups/`. `DriveBackupFile` is a typed value object for listing results.
- **BackupService** (`domain/services/`): orchestrates the above; owns `autoBackupIfConnected()` (fire-and-forget, never throws to caller). Checks `isAuthorizedSilently()` before upload to avoid background sign-in dialogs.

### Auto-backup triggers (all wired)
1. After every `saveAndPrint()` in `InvoiceDetailViewModel` — fire-and-forget via `autoBackupIfConnected()`
2. At app startup — only if last backup > 24 h ago and a backup has been done before (`_StartupController` in `app.dart`)
3. Reminder banner in `InvoiceListScreen` if last backup > 3 days ago (or never backed up)

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
| Client Android (type 1) | `833854972385-1pq3th38qkft9lnm5o2jjvif7g3jktuv.apps.googleusercontent.com` |
| Client Web Application (type 3) | `833854972385-n4p30ffkidfgnhut5de9nm63u0a5n01o.apps.googleusercontent.com` |
| `serverClientId` dans `main.dart` | client Web ci-dessus |
| Scope Drive | `drive.file` (fichiers créés par l'app uniquement) |
| Écran de consentement | Mode **Test** — ajouter chaque utilisateur manuellement dans "Utilisateurs test" |
| Utilisateur test configuré | `abdoullahkcoulibaly1@gmail.com` |

**Pour release (production):** changer le SHA-1 debug par le SHA-1 de la clé de signature release, publier l'écran de consentement OAuth (vérification Google requise si scope sensible).

**Fichiers Android concernés:**
- `android/app/google-services.json` — contient les deux clients OAuth (type 1 + type 3)
- `android/app/src/main/kotlin/com/kemogoha/goldinvoices/MainActivity.kt` — package corrigé
- `main.dart` — `GoogleSignIn.instance.initialize(serverClientId: '...')` appelé avant `runApp`

## UI Conventions

- Dark palette in `core/constants/app_colors.dart`: background `0xFF1A1A2E`, table bg `0xFF16213E`, header `0xFF0F3460`, carat accent red `0xFFE94560`, border `0xFF2D3561`
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
- `google_sign_in` v7 API: `GoogleSignIn.instance.initialize()` called once in `main.dart` (before `runApp`); authorization via `authorizationClient.authorizationHeaders(_scopes, promptIfNecessary: bool)` — no `GoogleSignIn(scopes: [...])` constructor style
- `InvoiceRepositoryImpl` receives both `AppDatabase` and `GoldBarCalculatorService` — it calls the calculator internally so DAOs stay pure data-access
- Comma input (`replaceAll(',', '.')`) needed before `double.tryParse()` for FR locale keyboards

## Out of Scope

No customer/client entity, no authentication, no multi-user, no sync conflict resolution, no push notifications for backup reminders.

## New UX Phase

Replaces the current 3-screen flow (List → Form → Detail) with:
- **`InvoiceEntryScreen`** — single home screen combining base price input, poids+eaux entry card, real-time preview, line table, and Save & Print
- **`AppShell`** — root `Scaffold` wrapping `InvoiceEntryScreen` with `AppDrawer` (Drawer nav) and `BackupStatusDot` in AppBar
- **`InvoiceHistoryScreen`** — accessed from Drawer; read-only list of saved invoices
- **`InvoiceDetailScreen`** (new version) — read-only detail + Reprint; no longer handles draft editing

New ViewModels needed:
- `InvoiceEntryViewModel` — merges concerns of `InvoiceFormViewModel` + `InvoiceDetailViewModel`: manages basePrice, grossWeight, waterWeight, live preview (`currentPreview`), draft lifecycle, line list, `canAddLine`, `isSavingAndPrinting`, `shouldShowBackupReminder`/`backupReminderMessage`/`refreshBackupStatus()`
- `InvoiceHistoryViewModel` — watches saved invoices, loads selected invoice + its lines for detail view, `reprintInvoice()`

New routes:
```
/           → AppShell (InvoiceEntryScreen body)
/history    → InvoiceHistoryScreen
/history/:id → InvoiceDetailScreen(invoiceId)
/backup     → BackupScreen (unchanged)
```

Key UX behaviors for `InvoiceEntryScreen`:
- Base price persists across "Ajouter barre" — only gross/water fields clear
- After clear: focus returns to gross weight field automatically
- Preview shows `—` placeholders when inputs are empty/invalid
- After "Enregistrer & Imprimer": all fields clear, table empties, ready for new invoice immediately
- `BackupReminderBanner` above entry form; `BackupStatusDot` (colored circle) in AppBar

**Confirm with user before each step.**

```
Step 1. app/app.dart — AppShell widget (Scaffold + AppBar + AppDrawer + InvoiceEntryScreen)
Step 2. app/router.dart — new routes (/, /history, /history/:id, /backup)
Step 3. features/invoice/widgets/app_drawer.dart — History + Backup items
Step 4. features/invoice/widgets/backup_status_dot.dart
Step 5. features/invoice/viewmodels/invoice_entry_viewmodel.dart
Step 6. features/invoice/widgets/ — _BasePriceField, _WeightField, _PreviewBlock, _AddBarButton
Step 7. features/invoice/widgets/invoice_table.dart — update/reuse for EntryScreen + DetailScreen
Step 8. features/invoice/views/invoice_entry_screen.dart — full assembly, controller management, responsive layout
Step 9. features/invoice/viewmodels/invoice_history_viewmodel.dart
Step 10. features/invoice/views/invoice_history_screen.dart
Step 11. features/invoice/views/invoice_detail_screen.dart — replace with read-only + Reprint
Step 12. app/di.dart — add InvoiceEntryViewModel, InvoiceHistoryViewModel providers
```
