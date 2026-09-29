import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/invoices/models/create_invoice_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_item_model.dart';
import 'package:invoice_app/features/invoices/presentation/screens/create_invoice_screen.dart';
import 'package:invoice_app/features/invoices/presentation/widgets/invoice_summary_card.dart';
import 'package:invoice_app/features/invoices/providers/create_invoice_provider.dart';

void main() {
  group('Create Invoice Calculation Tests', () {
    test('Prompt Example 1: Qty=1, UnitPrice=5000, Discount=0, Tax=5%', () {
      final state = CreateInvoiceState(
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
      );

      expect(state.subtotal, 5000.0);
      expect(state.discountAmount, 0.0);
      expect(state.taxableAmount, 5000.0);
      expect(state.taxAmount, 250.0);
      expect(state.grandTotal, 5250.0);
    });

    test('Prompt Discount & Tax Calculation: Subtotal=50000, Discount=9.5%, Tax=5.5%', () {
      final state = CreateInvoiceState(
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

      expect(state.subtotal, 50000.0);
      expect(state.discountAmount, 4750.0);
      expect(state.taxableAmount, 45250.0);
      expect(state.taxAmount, 2488.75);
      expect(state.grandTotal, 47738.75);
    });

    test('Prompt Example 2: Qty=2, UnitPrice=5000, Discount=10%, Tax=5%', () {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Website Development',
            quantity: 2,
            unitPrice: 5000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 10.0,
        taxRate: 5.0,
      );

      expect(state.subtotal, 10000.0);
      expect(state.discountAmount, 1000.0);
      expect(state.taxableAmount, 9000.0);
      expect(state.taxAmount, 450.0);
      expect(state.grandTotal, 9450.0);
    });

    test('Subtotal AED 55,000 at 5% tax: Tax = AED 2,750.00, Grand Total = AED 57,750.00', () {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Enterprise ERP',
            quantity: 1,
            unitPrice: 55000.0,
          ),
        ],
        discountType: DiscountType.none,
        discountValue: 0.0,
        taxRate: 5.0,
      );

      expect(state.subtotal, 55000.0);
      expect(state.discountAmount, 0.0);
      expect(state.taxableAmount, 55000.0);
      expect(state.taxAmount, 2750.0);
      expect(state.grandTotal, 57750.0);
    });

    test('Subtotal AED 55,000 at 5.5% tax: Tax = AED 3,025.00, Grand Total = AED 58,025.00', () {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Enterprise ERP',
            quantity: 1,
            unitPrice: 55000.0,
          ),
        ],
        discountType: DiscountType.none,
        discountValue: 0.0,
        taxRate: 5.5,
      );

      expect(state.subtotal, 55000.0);
      expect(state.discountAmount, 0.0);
      expect(state.taxableAmount, 55000.0);
      expect(state.taxAmount, 3025.0);
      expect(state.grandTotal, 58025.0);
    });

    test('Subtotal AED 55,000 at 10% tax: Tax = AED 5,500.00, Grand Total = AED 60,500.00', () {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Enterprise ERP',
            quantity: 1,
            unitPrice: 55000.0,
          ),
        ],
        discountType: DiscountType.none,
        discountValue: 0.0,
        taxRate: 10.0,
      );

      expect(state.subtotal, 55000.0);
      expect(state.discountAmount, 0.0);
      expect(state.taxableAmount, 55000.0);
      expect(state.taxAmount, 5500.0);
      expect(state.grandTotal, 60500.0);
    });

    test('Tax calculation with zero tax: Subtotal=5000, Tax=0%', () {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Item',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ],
        taxRate: 0.0,
      );

      expect(state.subtotal, 5000.0);
      expect(state.taxAmount, 0.0);
      expect(state.grandTotal, 5000.0);
    });

    test('Tax calculation with maximum tax: Subtotal=5000, Tax=100%', () {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Item',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ],
        taxRate: 100.0,
      );

      expect(state.subtotal, 5000.0);
      expect(state.taxAmount, 5000.0);
      expect(state.grandTotal, 10000.0);
    });

    test('Fixed discount calculation and clamping', () {
      final state = CreateInvoiceState(
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
        discountType: DiscountType.fixed,
        discountValue: 500.0,
        taxRate: 5.0,
      );

      expect(state.subtotal, 5000.0);
      expect(state.discountAmount, 500.0);
      expect(state.taxableAmount, 4500.0);
      expect(state.taxAmount, 225.0);
      expect(state.grandTotal, 4725.0);
    });

    test('Provider state operations: add, remove, update item, change quantity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createInvoiceProvider.notifier);

      expect(container.read(createInvoiceProvider).subtotal, 5000.0);

      notifier.incrementQuantity('item_1');
      expect(container.read(createInvoiceProvider).subtotal, 10000.0);

      notifier.decrementQuantity('item_1');
      expect(container.read(createInvoiceProvider).subtotal, 5000.0);

      notifier.addItem(description: 'UI/UX Design', quantity: 2, unitPrice: 2500.0);
      expect(container.read(createInvoiceProvider).items.length, 2);
      expect(container.read(createInvoiceProvider).subtotal, 10000.0);

      notifier.updateItem('item_1', unitPrice: 6000.0);
      expect(container.read(createInvoiceProvider).subtotal, 11000.0);

      notifier.removeItem('item_1');
      expect(container.read(createInvoiceProvider).items.length, 1);
      expect(container.read(createInvoiceProvider).subtotal, 5000.0);
    });

    test('Tax rate validation in CreateInvoiceNotifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createInvoiceProvider.notifier);
      notifier.setCustomer('ABC Trading');

      // 1. Default tax = 5%
      expect(container.read(createInvoiceProvider).taxRate, 5.0);
      expect(notifier.validate(), isNull);

      // 2. Tax = 0%
      notifier.updateTaxRate(0.0);
      expect(container.read(createInvoiceProvider).taxRate, 0.0);
      expect(notifier.validate(), isNull);

      // 3. Tax = 5%
      notifier.updateTaxRate(5.0);
      expect(container.read(createInvoiceProvider).taxRate, 5.0);
      expect(notifier.validate(), isNull);

      // 4. Tax = 5.5%
      notifier.updateTaxRate(5.5);
      expect(container.read(createInvoiceProvider).taxRate, 5.5);
      expect(notifier.validate(), isNull);

      // 5. Tax = 100%
      notifier.updateTaxRate(100.0);
      expect(container.read(createInvoiceProvider).taxRate, 100.0);
      expect(notifier.validate(), isNull);

      // 6. Tax > 100% rejected (provider must NOT silently become 121)
      notifier.updateTaxRate(121.0);
      expect(container.read(createInvoiceProvider).taxRate, 100.0);

      // 7. Negative tax rejected (provider must NOT silently become -2)
      notifier.updateTaxRate(-2.0);
      expect(container.read(createInvoiceProvider).taxRate, 100.0);
    });

    test('General validation tests (customer, dates, items)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createInvoiceProvider.notifier);

      expect(notifier.validate(), 'Please select a customer');

      notifier.setCustomer('ABC Trading');
      expect(notifier.validate(), isNull);

      notifier.setDueDate(DateTime(2026, 9, 20));
      expect(notifier.validate(), 'Due date cannot be before invoice date');
    });
  });

  group('Tax Field State Synchronization & Live Calculation Tests', () {
    testWidgets('Initial: TextField=5, Provider=5, Summary=Tax (5%)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(CreateInvoiceScreen)));

      // TextField = 5
      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');
      final TextField taxField = tester.widget(taxFieldFinder);
      expect(taxField.controller?.text, '5');

      // Provider = 5
      expect(container.read(createInvoiceProvider).taxRate, 5.0);

      // Summary = Tax (5%)
      expect(find.text('Tax (5%)'), findsOneWidget);
      expect(find.text('AED 250.00'), findsOneWidget);
    });

    testWidgets('Change 5 -> 10: TextField=10, Provider=10, Summary=Tax (10%)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(CreateInvoiceScreen)));
      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');

      await tester.enterText(taxFieldFinder, '10');
      await tester.pumpAndSettle();

      final TextField taxField = tester.widget(taxFieldFinder);
      expect(taxField.controller?.text, '10');
      expect(container.read(createInvoiceProvider).taxRate, 10.0);
      expect(find.text('Tax (10%)'), findsOneWidget);
      expect(find.text('AED 500.00'), findsOneWidget);
      expect(find.text('AED 5,500.00'), findsOneWidget);
    });

    testWidgets('Change 10 -> 5.5: TextField=5.5, Provider=5.5, Summary=Tax (5.5%)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(CreateInvoiceScreen)));
      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');

      await tester.enterText(taxFieldFinder, '10');
      await tester.pumpAndSettle();

      await tester.enterText(taxFieldFinder, '5.5');
      await tester.pumpAndSettle();

      final TextField taxField = tester.widget(taxFieldFinder);
      expect(taxField.controller?.text, '5.5');
      expect(container.read(createInvoiceProvider).taxRate, 5.5);
      expect(find.text('Tax (5.5%)'), findsOneWidget);
      expect(find.text('AED 275.00'), findsOneWidget);
      expect(find.text('AED 5,275.00'), findsOneWidget);
    });

    testWidgets('Change 5.5 -> 0: TextField=0, Provider=0, Summary=Tax (0%), Tax amount=0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(CreateInvoiceScreen)));
      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');

      await tester.enterText(taxFieldFinder, '0');
      await tester.pumpAndSettle();

      final TextField taxField = tester.widget(taxFieldFinder);
      expect(taxField.controller?.text, '0');
      expect(container.read(createInvoiceProvider).taxRate, 0.0);
      expect(find.text('Tax (0%)'), findsOneWidget);
      expect(find.text('AED 0.00'), findsWidgets);
      expect(find.text('AED 5,000.00'), findsWidgets);
    });

    testWidgets('Invalid: 5 -> 121 shows error, Provider does NOT silently become 121',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(CreateInvoiceScreen)));
      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');

      await tester.enterText(taxFieldFinder, '121');
      await tester.pumpAndSettle();

      expect(find.text('Tax rate must be between 0% and 100%.'), findsOneWidget);
      expect(container.read(createInvoiceProvider).taxRate, isNot(121.0));
      expect(container.read(createInvoiceProvider).taxRate, 5.0);
    });

    testWidgets('Invalid: 5 -> -2 shows error, Provider does NOT silently become -2',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(CreateInvoiceScreen)));
      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');

      await tester.enterText(taxFieldFinder, '-2');
      await tester.pumpAndSettle();

      expect(find.text('Tax rate must be between 0% and 100%.'), findsOneWidget);
      expect(container.read(createInvoiceProvider).taxRate, isNot(-2.0));
      expect(container.read(createInvoiceProvider).taxRate, 5.0);
    });

    testWidgets('Invalid text rejected: abc shows error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');
      await tester.enterText(taxFieldFinder, 'abc');
      await tester.pumpAndSettle();

      expect(find.text('Tax rate must be between 0% and 100%.'), findsOneWidget);
    });

    testWidgets('Tax field does not accidentally concatenate default value on focus',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final taxFieldFinder = find.widgetWithText(TextField, 'Tax Rate (%)');
      await tester.ensureVisible(taxFieldFinder);
      await tester.pumpAndSettle();

      await tester.tap(taxFieldFinder);
      await tester.pumpAndSettle();

      final TextField textField = tester.widget(taxFieldFinder);
      expect(textField.controller?.selection.baseOffset, 0);
      expect(textField.controller?.selection.extentOffset, 1);
    });

    testWidgets('Customer selector opens bottom sheet and updates selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Select Customer'), findsWidgets);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);
      expect(find.text('ABC Trading'), findsOneWidget);

      await tester.tap(find.text('ZAHURUDDIN'));
      await tester.pumpAndSettle();

      expect(find.text('ZAHURUDDIN'), findsOneWidget);
    });

    testWidgets('Save Draft shows SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Draft'));
      await tester.pump();

      expect(find.text('Draft saved locally'), findsOneWidget);
    });

    testWidgets('Save Invoice validates customer selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save Invoice'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Invoice'));
      await tester.pump();

      expect(find.text('Please select a customer'), findsOneWidget);
    });

    for (final width in [360.0, 390.0, 412.0]) {
      testWidgets('Create Invoice renders with no overflow on width: ${width}px',
          (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CreateInvoiceScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Create Invoice'), findsOneWidget);
        expect(find.text('Create a new invoice'), findsOneWidget);

        await tester.ensureVisible(find.text('Save Invoice'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Save Invoice'), findsOneWidget);
      });
    }
  });

  group('Discount Percentage Display Tests', () {
    testWidgets('Summary displays exact discount percentage: 9.5% -> Discount (9.5%)',
        (WidgetTester tester) async {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Item',
            quantity: 1,
            unitPrice: 50000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 9.5,
        taxRate: 5.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceSummaryCard(state: state),
          ),
        ),
      );

      expect(find.text('Discount (9.5%)'), findsOneWidget);
      expect(find.text('- AED 4,750.00'), findsOneWidget);
      expect(find.text('AED 2,488.75'), findsOneWidget);
      expect(find.text('AED 47,738.75'), findsOneWidget);
    });

    testWidgets('Summary displays exact discount percentage: 10% -> Discount (10%)',
        (WidgetTester tester) async {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Item',
            quantity: 1,
            unitPrice: 10000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 10.0,
        taxRate: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceSummaryCard(state: state),
          ),
        ),
      );

      expect(find.text('Discount (10%)'), findsOneWidget);
      expect(find.text('- AED 1,000.00'), findsOneWidget);
    });

    testWidgets('Summary displays exact discount percentage: 7.25% -> Discount (7.25%)',
        (WidgetTester tester) async {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Item',
            quantity: 1,
            unitPrice: 10000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 7.25,
        taxRate: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceSummaryCard(state: state),
          ),
        ),
      );

      expect(find.text('Discount (7.25%)'), findsOneWidget);
      expect(find.text('- AED 725.00'), findsOneWidget);
    });

    testWidgets('Summary displays exact discount percentage: 0% -> Discount',
        (WidgetTester tester) async {
      final state = CreateInvoiceState(
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Item',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 0.0,
        taxRate: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceSummaryCard(state: state),
          ),
        ),
      );

      expect(find.text('Discount'), findsOneWidget);
      expect(find.text('AED 0.00'), findsWidgets);
    });

    testWidgets('Interactive test: selecting Percentage and typing 9.5 updates Summary to Discount (9.5%)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

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

      final discountSummary = find.text('Discount (9.5%)');
      await tester.ensureVisible(discountSummary);
      await tester.pumpAndSettle();

      expect(discountSummary, findsOneWidget);
    });
  });
}
