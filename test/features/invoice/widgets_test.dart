import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gold_bar_invoice_management/core/constants/app_colors.dart';
import 'package:gold_bar_invoice_management/domain/entities/invoice_line.dart';
import 'package:gold_bar_invoice_management/features/invoice/widgets/draft_banner.dart';
import 'package:gold_bar_invoice_management/features/invoice/widgets/invoice_table.dart';
import 'package:gold_bar_invoice_management/features/invoice/widgets/save_and_print_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  const line = InvoiceLine(
    id: 1,
    invoiceId: 1,
    barNumber: 1,
    basePrice: 70200,
    grossWeight: 430.87,
    waterWeight: 23.67,
    density: 18.20,
    carat: 22.32,
    unitPrice: 71221.09,
    amount: 30687031.02,
  );

  group('DraftBanner', () {
    testWidgets('shows date and triggers callbacks', (tester) async {
      var resumed = false;
      var discarded = false;
      await tester.pumpWidget(_wrap(DraftBanner(
        draftDate: DateTime(2026, 6, 6),
        onResume: () => resumed = true,
        onDiscard: () => discarded = true,
      )));

      expect(find.textContaining('06/06/2026'), findsOneWidget);

      await tester.tap(find.text('Reprendre'));
      expect(resumed, true);

      await tester.tap(find.text('Abandonner'));
      expect(discarded, true);
    });
  });

  group('InvoiceTable', () {
    testWidgets('renders FR-formatted values, carat in red', (tester) async {
      await tester.pumpWidget(_wrap(const InvoiceTable(lines: [line])));

      expect(find.text('30 687 031,02'), findsOneWidget);
      expect(find.text('430,87'), findsOneWidget);

      final caratText = tester.widget<Text>(find.text('22,32'));
      expect(caratText.style?.color, AppColors.accentCarat);
    });

    testWidgets('delete icon only in draft mode', (tester) async {
      await tester.pumpWidget(_wrap(const InvoiceTable(lines: [line])));
      expect(find.byIcon(Icons.delete_outline), findsNothing);

      InvoiceLine? deleted;
      await tester.pumpWidget(_wrap(InvoiceTable(
        lines: const [line],
        onDeleteLine: (l) => deleted = l,
      )));
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted?.id, 1);
    });
  });

  group('SaveAndPrintButton', () {
    testWidgets('disabled when not enabled, spinner while saving',
        (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(SaveAndPrintButton(
        enabled: false,
        isSaving: false,
        onPressed: () => pressed = true,
      )));

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, false);

      await tester.pumpWidget(_wrap(SaveAndPrintButton(
        enabled: true,
        isSaving: true,
        onPressed: () {},
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Impression…'), findsOneWidget);
    });
  });
}
