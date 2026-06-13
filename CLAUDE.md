# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter mobile app for managing gold bar sale invoices. Single operator, single-user, **offline-first**. Replaces a desktop application the client is used to — the UI must be dense, tabular, and faithful to the original (dark theme, FR number formatting).

**Current state:** all 13 build steps implemented (core, entities, calculator, Drift DB + DAOs, repository, PrintService, ViewModels, views/widgets, sync, DI/router/app). 59 tests passing. Not yet done: Supabase project setup (tables + RLS), real-device testing, auth (out of scope).

## Commands

```bash
flutter pub get                          # install deps
flutter run                              # run app (offline-only without dart-defines)
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...   # with cloud sync
flutter test                             # all tests
flutter test test/domain/services/gold_bar_calculator_service_test.dart   # single test file
flutter test --plain-name "line 1"       # single test by name
flutter analyze                          # lint
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift code (after table changes)
```

Without Supabase dart-defines the app runs fully offline: SyncService is not initialized, operations accumulate in sync_queue (amber chip). `SYNC_USER_ID` dart-define overrides the static user id (default `operator-1`).

## Tech Stack

- State management: `provider` (ChangeNotifier + ChangeNotifierProvider)
- Local DB: `drift` (SQLite) — **single source of truth**
- Cloud: `supabase_flutter` — backup/restore only, never the source of truth
- Connectivity: `connectivity_plus` triggers automatic sync
- PDF/print: `pdf` + `printing` packages
- Routing: GoRouter; DI via Provider tree in `app/di.dart`

## Out of Scope

No customer/client entity, no real authentication (static local `userId` for Supabase), no multi-user, no sync conflict resolution.

## Architecture — Strict MVVM, feature-first

Reference: https://docs.flutter.dev/app-architecture/case-study/data-layer

```
lib/
├── core/            # constants (app_colors), errors, extensions, utils (formatters, responsive)
├── data/
│   ├── local/       # drift database, DAOs (InvoiceDao, InvoiceLineDao, SyncQueueDao), table defs
│   ├── remote/      # supabase services
│   └── repositories/# InvoiceRepositoryImpl, etc.
├── domain/
│   ├── entities/    # Invoice, InvoiceLine, InvoiceLinePreview (pure Dart)
│   ├── repositories/# abstract interfaces (IInvoiceRepository)
│   └── services/    # GoldBarCalculatorService, PrintService
├── features/
│   ├── invoice/     # viewmodels / views / widgets
│   └── sync/        # SyncViewModel, SyncService, SyncQueue
└── app/             # app.dart, router.dart, di.dart
```

Layering rules (non-negotiable):
1. No logic in widgets — all logic in ViewModels
2. ViewModels never touch Drift directly — always through repository interfaces
3. No `BuildContext` in services or repositories
4. Strong types everywhere — never pass `Map<String, dynamic>` where an entity fits
5. Every formula in `GoldBarCalculatorService` gets a doc-comment with the math written out
6. Batch calculations over 50 lines go through `compute()` / Isolate

## Business Domain — Calculation Formulas (CRITICAL)

The core of the app. Encapsulated in `GoldBarCalculatorService`, unit tested against real capture data. One invoice line = one gold bar (`GoldBar`), weighed by the hydrostatic (Archimedes) method.

| Domain (FR)      | Code name     | Meaning                                  |
|------------------|---------------|------------------------------------------|
| Poids brut       | `grossWeight` | weight in air (grams)                    |
| Eaux             | `waterWeight` | weight submerged in water                |
| Densité          | `density`     | grossWeight / waterWeight                |
| Carat            | `carat`       | purity (shown in red in UI and PDF)      |
| U/BASE           | `unitPrice`   | price per gram for this bar              |
| Montant          | `amount`      | line total                               |
| Base             | `basePrice`   | market reference price, same for all lines of an invoice |

The 4 formulas, applied in order:

```dart
density   = truncate2(grossWeight / waterWeight);
carat     = truncate2((density - 10.51) * 52.838 / density);   // proprietary: A=10.51 alloy density, B=52.838
unitPrice = (basePrice / 22) * carat;
amount    = unitPrice * grossWeight;
```

**Truncation is mandatory, not rounding.** The original desktop software truncates density and carat to 2 decimals before the next step (`truncate2(x) = (x*100).truncateToDouble()/100`). Without it the verification data below is NOT reproducible: 30.22/1.63 gives raw density 18.53988 → must become 18.53 (not 18.54), raw carat 22.8849 → expected 22.86 (truncated from 22.8688 computed on truncated density). unitPrice and amount keep full double precision; rounding only at display.

Verification data (basePrice = 70200) — unit tests must match these:

```
Line 1: gross=430.87, water=23.67 → density=18.20, carat=22.32, unitPrice=71221.09, amount=30 687 031.02
Line 2: gross=126.39, water=6.87  → carat=22.64, amount=9 130 689.11
Line 3: gross=73.18,  water=3.98  → carat=22.62, amount=5 282 012.85
Line 4: gross=37.69,  water=2.06  → carat=22.47, amount=2 702 362.64
Line 5: gross=30.22,  water=1.63  → carat=22.86, amount=2 204 373.23
Totals: grossWeight=698.35, waterWeight=38.21, amount=50 006 468.85
```

All calculations use `double` — never `int` for monetary values. Display rounded to 2 decimals. Calculated values (density, carat, unitPrice, amount) are **stored** in the `invoice_lines` table, not recomputed on read.

## Invoice Lifecycle — Draft Safety

`InvoiceStatus` enum: `draft` | `saved`. Stored as text in the `invoices.status` column.

- "New Invoice" → INSERT with status `draft` **immediately** in Drift (survives app kill)
- Each line added → INSERT line + UPDATE invoice totals (barCount, totalGrossWeight, totalWaterWeight, totalAmount) immediately — **no sync enqueue here**
- "Save & Print" → status → `saved`, enqueue invoice + lines in `sync_queue`, generate PDF, open `Printing.layoutPdf()` (native print/share sheet)
- App reopen: query for `status = 'draft'` → show `DraftBanner` at top of InvoiceListScreen with Resume/Discard. Discard deletes draft + its lines.

Only `saved` invoices are ever synced or restored from Supabase.

## Sync

`SyncService.init()` listens to `connectivity_plus`; on reconnect it flushes `sync_queue` (tableName, operation CREATE/UPDATE/DELETE, JSON payload, attempts counter — stop after 3 failures). `syncedAt = NULL` means not synced. `SyncStatusChip` always visible in AppBar: green Synced / amber N pending / spinner Syncing / red error.

## UI Conventions

- Dark palette in `core/constants/app_colors.dart`: background `0xFF1A1A2E`, table bg `0xFF16213E`, header `0xFF0F3460`, carat accent red `0xFFE94560`, border `0xFF2D3561`
- **Carat column always red**; Base column dimmed (shared fixed value)
- Numbers: FR locale via `intl` `NumberFormat('#,##0.00', 'fr_FR')` — space thousands separator, comma decimal (e.g. `30 687 031,02`)
- Responsive: `core/utils/responsive.dart` — mobile < 600px gets horizontally scrollable table, tablet ≥ 600px gets full-width table
- Invoice header: `Bamako le: [date]` + `Nombre Barres: [n]` — location and issueDate editable, barCount computed
- Save & Print button disabled when no lines exist
- PDF (PrintService): landscape, `pw.TableBorder` grid, carat column in `PdfColors.red`, same FR formatting as UI

## Implementation Gotchas

- Drift row classes are renamed via `@DataClassName` (`InvoiceRow`, `InvoiceLineRow`, `SyncQueueRow`) to avoid clashing with domain entities; mapping lives in `data/repositories/invoice_mappers.dart`
- `sync_queue.table_name` is the Dart getter `targetTable` (drift's `Table` base class owns `tableName`)
- `NumberFormatter` strips intl's U+202F narrow no-break space (fr_FR grouping) — PDF base fonts can't encode it
- `invoice_lines.invoiceId` has `onDelete: KeyAction.cascade` + `PRAGMA foreign_keys = ON` in `beforeOpen` — discarding a draft deletes its lines automatically
- basePrice is locked once an invoice has lines (`updateDraftHeader` throws) — stored line amounts would diverge from the header
- SyncService stops the flush at the first failure (queue order = invoices before their lines; a failure usually means offline)

## Data Model Notes

Three Drift tables: `invoices` (with status, denormalized totals, syncedAt), `invoice_lines` (FK to invoices, barNumber, stored calculated columns, syncedAt), `sync_queue`. Invoice `invoiceNumber` is unique text. Defaults: location `'Bamako'`, status `'draft'`.

## Development Order (confirm with user before each step)

1. `core/` — constants, theme, colors, formatters, responsive
2. `domain/entities/` — Invoice (+ InvoiceStatus), InvoiceLine, InvoiceLinePreview
3. `domain/services/` — GoldBarCalculatorService + unit tests
4. `data/local/database/` — Drift AppDatabase
5. `data/local/dao/` — InvoiceDao, InvoiceLineDao, SyncQueueDao
6. `domain/repositories/` — IInvoiceRepository
7. `data/repositories/` — InvoiceRepositoryImpl
8. `domain/services/` — PrintService
9. `features/invoice/viewmodels/`
10. `features/invoice/views/` — InvoiceListScreen (+ DraftBanner), InvoiceDetailScreen, InvoiceFormScreen, InvoiceLineFormScreen (bottom sheet with real-time calculation preview)
11. `features/invoice/widgets/`
12. `features/sync/`
13. `app/` — di.dart, router.dart, app.dart

Not in scope yet: Supabase auth/login screen.
