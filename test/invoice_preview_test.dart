import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/invoices/models/create_invoice_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_item_model.dart';
import 'package:invoice_app/features/invoices/presentation/screens/create_invoice_screen.dart';
import 'package:invoice_app/features/invoices/presentation/screens/invoice_preview_screen.dart';

void main() {
  group('Invoice Preview Screen & PDF Actions Tests', () {
    testWidgets('Invoice Preview renders all required sections and data',
        (WidgetTester tester) async {
      final testState = CreateInvoiceState(
        invoiceNumber: 'INV-006',
        customer: 'ZAHURUDDIN',
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Website Development',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ],
        discountType: DiscountType.none,
        discountValue: 0.0,
        taxRate: 5.0,
        notes: 'Payment due within 14 days.',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(invoiceState: testState),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Title and Header
      expect(find.text('Invoice Preview'), findsWidgets);
      expect(
        find.text('Review your invoice before generating the PDF'),
        findsOneWidget,
      );

      // 2. Company Info (Mock data)
      expect(find.text('YOUR COMPANY'), findsOneWidget);
      expect(find.text('Professional Invoice'), findsOneWidget);
      expect(find.textContaining('123 Business Street'), findsOneWidget);
      expect(find.textContaining('+971 50 000 0000'), findsOneWidget);
      expect(find.textContaining('hello@yourcompany.com'), findsOneWidget);

      // 3. Invoice Number & Dates
      expect(find.text('INVOICE'), findsOneWidget);
      expect(find.text('INV-006'), findsOneWidget);
      expect(find.text('26 Sep 2026'), findsOneWidget);
      expect(find.text('10 Oct 2026'), findsOneWidget);

      // 4. Customer
      expect(find.text('BILL TO'), findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);

      // 5. Items Table
      expect(find.text('Website Development'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // Qty
      expect(find.text('AED 5,000.00'), findsWidgets); // Rate and Amount

      // 6. Subtotal & Totals
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Tax (5%)'), findsOneWidget);
      expect(find.text('AED 250.00'), findsOneWidget);
      expect(find.text('Grand Total'), findsOneWidget);
      expect(find.text('AED 5,250.00'), findsOneWidget);

      // 7. Notes
      expect(find.text('NOTES & PAYMENT TERMS'), findsOneWidget);
      expect(find.text('Payment due within 14 days.'), findsOneWidget);

      // 8. Footer
      expect(find.text('Thank you for your business.'), findsOneWidget);
      expect(find.text('Generated with Invoice App'), findsOneWidget);

      // 9. Initial Actions
      expect(find.text('Generate PDF'), findsOneWidget);
      expect(find.text('Edit Invoice'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets(
        'Exact Discount & Tax calculation: Subtotal=50000, Discount=9.5%, Tax=5.5%',
        (WidgetTester tester) async {
      final testState = CreateInvoiceState(
        invoiceNumber: 'INV-006',
        customer: 'ZAHURUDDIN',
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Enterprise Solution',
            quantity: 1,
            unitPrice: 50000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 9.5,
        taxRate: 5.5,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(invoiceState: testState),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Subtotal
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('AED 50,000.00'), findsWidgets);

      // Discount (9.5%) - must not round
      expect(find.text('Discount (9.5%)'), findsOneWidget);
      expect(find.text('- AED 4,750.00'), findsOneWidget);

      // Tax (5.5%) - must not round
      expect(find.text('Tax (5.5%)'), findsOneWidget);
      expect(find.text('AED 2,488.75'), findsOneWidget);

      // Grand Total
      expect(find.text('Grand Total'), findsOneWidget);
      expect(find.text('AED 47,738.75'), findsOneWidget);
    });

    testWidgets(
        '1. Generate PDF stores bytes, generates INV-006.pdf, and reveals PDF actions',
        (WidgetTester tester) async {
      final key = GlobalKey<InvoicePreviewScreenState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              key: key,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially, PDF bytes are null and Generate PDF button is visible
      expect(key.currentState?.pdfBytes, isNull);
      expect(find.text('Generate PDF'), findsOneWidget);
      expect(find.text('Preview PDF'), findsNothing);

      // Tap Generate PDF
      await tester.tap(find.text('Generate PDF'));
      await tester.pumpAndSettle();

      // Verify bytes are stored in state
      expect(key.currentState?.pdfBytes, isNotNull);
      expect(key.currentState!.pdfBytes!.isNotEmpty, isTrue);

      // PDF Actions become available
      expect(find.text('PDF Actions'), findsOneWidget);
      expect(find.text('INV-006.pdf'), findsOneWidget);
      expect(find.text('Preview PDF'), findsOneWidget);
      expect(find.text('Share PDF'), findsOneWidget);
      expect(find.text('Print PDF'), findsOneWidget);
      expect(find.text('Save PDF'), findsOneWidget);
      expect(find.text('Edit Invoice'), findsOneWidget);
    });

    testWidgets(
        '2. Actions are disabled and show loading indicator while PDF is generating',
        (WidgetTester tester) async {
      final completer = Completer<bool>();
      final key = GlobalKey<InvoicePreviewScreenState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              key: key,
              onLayoutPdf: (bytes, name) async => completer.future,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate PDF'));
      await tester.pump();

      // In-flight loading state
      expect(key.currentState?.isGeneratingPdf, isTrue);
      expect(find.text('Generating PDF...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(true);
      await tester.pumpAndSettle();

      // Loading state cleared
      expect(key.currentState?.isGeneratingPdf, isFalse);
      expect(find.text('PDF Actions'), findsOneWidget);
    });

    testWidgets(
        '3. Actions cannot run when PDF bytes are null (shows "Please generate the PDF first.")',
        (WidgetTester tester) async {
      final key = GlobalKey<InvoicePreviewScreenState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              key: key,
              showActionsBeforeGeneration: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState?.pdfBytes, isNull);

      // Attempt Preview PDF while bytes are null
      await tester.tap(find.text('Preview PDF'));
      await tester.pump();
      expect(find.text('Please generate the PDF first.'), findsOneWidget);
      await tester.pumpAndSettle();

      // Attempt Share PDF while bytes are null
      await tester.tap(find.text('Share PDF'));
      await tester.pump();
      expect(find.text('Please generate the PDF first.'), findsOneWidget);
      await tester.pumpAndSettle();

      // Attempt Print PDF while bytes are null
      await tester.tap(find.text('Print PDF'));
      await tester.pump();
      expect(find.text('Please generate the PDF first.'), findsOneWidget);
      await tester.pumpAndSettle();

      // Attempt Save PDF while bytes are null
      await tester.tap(find.text('Save PDF'));
      await tester.pump();
      expect(find.text('Please generate the PDF first.'), findsOneWidget);
    });

    testWidgets(
        '4. Preview PDF action invokes preview callback with stored bytes and filename',
        (WidgetTester tester) async {
      bool previewInvoked = false;
      Uint8List? previewBytes;
      String? previewFilename;

      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              initialPdfBytes: dummyBytes,
              onPreviewPdf: (bytes, filename) async {
                previewInvoked = true;
                previewBytes = bytes;
                previewFilename = filename;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preview PDF'));
      await tester.pumpAndSettle();

      expect(previewInvoked, isTrue);
      expect(previewBytes, dummyBytes);
      expect(previewFilename, 'INV-006.pdf');
    });

    testWidgets(
        '5. Share PDF action invokes share callback with stored bytes and filename',
        (WidgetTester tester) async {
      bool shareInvoked = false;
      Uint8List? sharedBytes;
      String? sharedFilename;

      final dummyBytes = Uint8List.fromList([10, 20, 30]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              initialPdfBytes: dummyBytes,
              onSharePdf: (bytes, filename) async {
                shareInvoked = true;
                sharedBytes = bytes;
                sharedFilename = filename;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Share PDF'));
      await tester.pumpAndSettle();

      expect(shareInvoked, isTrue);
      expect(sharedBytes, dummyBytes);
      expect(sharedFilename, 'INV-006.pdf');
    });

    testWidgets(
        '6. Print PDF action invokes print callback with stored bytes and filename',
        (WidgetTester tester) async {
      bool printInvoked = false;
      Uint8List? printedBytes;
      String? printedFilename;

      final dummyBytes = Uint8List.fromList([100, 200]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              initialPdfBytes: dummyBytes,
              onPrintPdf: (bytes, filename) async {
                printInvoked = true;
                printedBytes = bytes;
                printedFilename = filename;
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Print PDF'));
      await tester.pumpAndSettle();

      expect(printInvoked, isTrue);
      expect(printedBytes, dummyBytes);
      expect(printedFilename, 'INV-006.pdf');
    });

    testWidgets('7. Save PDF action displays "Save PDF will be available soon."',
        (WidgetTester tester) async {
      final dummyBytes = Uint8List.fromList([1, 2]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              initialPdfBytes: dummyBytes,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save PDF'));
      await tester.pump();

      expect(find.text('Save PDF will be available soon.'), findsOneWidget);
    });

    test('8. Filename sanitization handles standard and invalid characters', () {
      expect(InvoicePreviewScreen.getPdfFilename('INV-006'), 'INV-006.pdf');
      expect(InvoicePreviewScreen.getPdfFilename('INV-123'), 'INV-123.pdf');
      expect(InvoicePreviewScreen.getPdfFilename('INV/2026/01'), 'INV_2026_01.pdf');
      expect(InvoicePreviewScreen.getPdfFilename('INV:01*?'), 'INV_01__.pdf');
      expect(InvoicePreviewScreen.getPdfFilename(''), 'INV-001.pdf');
      expect(InvoicePreviewScreen.getPdfFilename(null), 'INV-001.pdf');
    });

    testWidgets('9. Generate PDF error displays error SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: InvoicePreviewScreen(
              onLayoutPdf: (bytes, name) async {
                throw Exception('Generation failed');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate PDF'));
      await tester.pumpAndSettle();

      expect(
        find.text('Unable to generate invoice PDF. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets(
        '10. Save Invoice navigates to Preview and Edit returns with state preserved',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Select Customer
      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ZAHURUDDIN'));
      await tester.pumpAndSettle();

      // 2. Select Discount: Percentage 9.5
      final percentageChip = find.text('Percentage (%)');
      await tester.ensureVisible(percentageChip);
      await tester.pumpAndSettle();
      await tester.tap(percentageChip);
      await tester.pumpAndSettle();

      final discountField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == '10',
      );
      await tester.ensureVisible(discountField);
      await tester.pumpAndSettle();
      await tester.enterText(discountField, '9.5');
      await tester.pumpAndSettle();

      // 3. Set Tax Rate: 5.5
      final taxField = find.widgetWithText(TextField, 'Tax Rate (%)');
      await tester.ensureVisible(taxField);
      await tester.pumpAndSettle();
      await tester.enterText(taxField, '5.5');
      await tester.pumpAndSettle();

      // 4. Save Invoice -> Navigates to Preview
      final saveBtn = find.text('Save Invoice');
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify on Preview screen
      expect(find.text('Review your invoice before generating the PDF'),
          findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);
      expect(find.text('Discount (9.5%)'), findsOneWidget);
      expect(find.text('Tax (5.5%)'), findsOneWidget);

      // 5. Tap 'Edit' to return to Create Invoice
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      // Verify returned to Create Invoice with state intact
      expect(find.text('Create a new invoice'), findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);
      expect(find.text('Discount (9.5%)'), findsOneWidget);
      expect(find.text('Tax (5.5%)'), findsOneWidget);
    });

    testWidgets('11. Edit Invoice button returns to Create Invoice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select Customer
      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ABC Trading'));
      await tester.pumpAndSettle();

      // Save Invoice -> Preview
      final saveBtn = find.text('Save Invoice');
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('ABC Trading'), findsOneWidget);

      // Tap bottom 'Edit Invoice' button
      final editInvoiceBtn = find.text('Edit Invoice');
      await tester.tap(editInvoiceBtn);
      await tester.pumpAndSettle();

      // Verify returned to Create Invoice
      expect(find.text('Create a new invoice'), findsOneWidget);
      expect(find.text('ABC Trading'), findsOneWidget);
    });

    // Responsive screen width tests (360px, 390px, 412px) with PDF actions visible
    for (final width in [360.0, 390.0, 412.0]) {
      testWidgets(
          '12. Invoice Preview with PDF Actions renders with no overflow on width: ${width}px',
          (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 840.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final testState = CreateInvoiceState(
          invoiceNumber: 'INV-006',
          customer: 'ZAHURUDDIN',
          invoiceDate: DateTime(2026, 9, 26),
          dueDate: DateTime(2026, 10, 10),
          items: const [
            InvoiceItemModel(
              id: '1',
              description: 'Website Development and UI/UX Consulting Service',
              quantity: 2,
              unitPrice: 25000.0,
            ),
          ],
          discountType: DiscountType.percentage,
          discountValue: 9.5,
          taxRate: 5.5,
          notes: 'Payment due within 14 days.',
        );

        final dummyBytes = Uint8List.fromList([1, 2, 3]);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: InvoicePreviewScreen(
                invoiceState: testState,
                initialPdfBytes: dummyBytes,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('INV-006'), findsWidgets);
        expect(find.text('PDF Actions'), findsOneWidget);
        expect(find.text('Preview PDF'), findsOneWidget);
        expect(find.text('Share PDF'), findsOneWidget);
        expect(find.text('Print PDF'), findsOneWidget);
        expect(find.text('Save PDF'), findsOneWidget);
        expect(find.text('AED 47,738.75'), findsOneWidget);
      });
    }
  });
}
