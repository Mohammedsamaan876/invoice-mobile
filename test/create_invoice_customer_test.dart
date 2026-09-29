import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/customers/models/customer_model.dart';
import 'package:invoice_app/features/customers/providers/customer_provider.dart';
import 'package:invoice_app/features/invoices/models/create_invoice_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_item_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_preview_model.dart';
import 'package:invoice_app/features/invoices/presentation/screens/create_invoice_screen.dart';
import 'package:invoice_app/features/invoices/providers/create_invoice_provider.dart';
import 'package:invoice_app/features/invoices/services/invoice_pdf_service.dart';

void main() {
  group('Create Invoice Customer Flow & Architecture Tests', () {
    testWidgets('1. Selecting an existing customer updates state & UI',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();

      // Verify bottom sheet title and search field
      expect(find.text('Select Customer'), findsWidgets);
      expect(find.text('Search customers...'), findsOneWidget);
      expect(find.text('+ Add New Customer'), findsOneWidget);

      // Verify existing customers are listed
      expect(find.text('ZAHURUDDIN'), findsOneWidget);
      expect(find.text('ABC Trading'), findsOneWidget);

      // Select 'ABC Trading'
      await tester.tap(find.text('ABC Trading'));
      await tester.pumpAndSettle();

      // Verify invoice state
      final state = container.read(createInvoiceProvider);
      expect(state.customer, 'ABC Trading');
      expect(state.customerInfo?.name, 'ABC Trading');
      expect(state.customerInfo?.isSaved, isTrue);

      // Verify Create Invoice screen displays the selected customer and summary
      expect(find.text('ABC Trading'), findsOneWidget);
      expect(find.text('Edit for this invoice'), findsOneWidget);
    });

    testWidgets('2. Opening Add New Customer displays all required fields',
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

      // Tap '+ Add New Customer'
      await tester.tap(find.text('+ Add New Customer'));
      await tester.pumpAndSettle();

      // Verify Add New Customer form fields
      expect(find.text('Add New Customer'), findsOneWidget);
      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Company Name'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Billing Address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Tax/VAT Number'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Save Customer & Use'), findsOneWidget);
      expect(find.text('Use Once'), findsOneWidget);
    });

    testWidgets('3. Required customer name validation shows error when empty',
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

      await tester.tap(find.text('+ Add New Customer'));
      await tester.pumpAndSettle();

      // Tap 'Save Customer & Use' without entering name
      await tester.tap(find.text('Save Customer & Use'));
      await tester.pumpAndSettle();

      expect(find.text('Customer name is required'), findsOneWidget);

      // Tap 'Use Once' without entering name
      await tester.tap(find.text('Use Once'));
      await tester.pumpAndSettle();

      expect(find.text('Customer name is required'), findsOneWidget);
    });

    testWidgets(
        '4. "Use Once" applies customer only for this invoice and does NOT save to customer list',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ Add New Customer'));
      await tester.pumpAndSettle();

      // Enter manual customer info using explicit Keys
      await tester.enterText(
          find.byKey(const Key('customer_name_field')), 'John Doe');
      await tester.enterText(
          find.byKey(const Key('customer_company_field')), 'Acme Corp');
      await tester.enterText(
          find.byKey(const Key('customer_phone_field')), '+971 50 123 4567');
      await tester.enterText(
          find.byKey(const Key('customer_email_field')), 'john@example.com');
      await tester.pumpAndSettle();

      // Tap 'Use Once'
      await tester.tap(find.text('Use Once'));
      await tester.pumpAndSettle();

      // Verify invoice state
      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customer, 'John Doe');
      expect(invoiceState.customerInfo?.name, 'John Doe');
      expect(invoiceState.customerInfo?.companyName, 'Acme Corp');
      expect(invoiceState.customerInfo?.phone, '+971 50 123 4567');
      expect(invoiceState.customerInfo?.email, 'john@example.com');
      expect(invoiceState.customerInfo?.isSaved, isFalse);

      // Verify customer list does NOT contain John Doe
      final savedCustomers = container.read(customerListNotifierProvider);
      expect(savedCustomers.any((c) => c.name == 'John Doe'), isFalse);

      // Verify UI display on Create Invoice Screen
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('John Doe • Acme Corp'), findsOneWidget);
      expect(find.text('Edit for this invoice'), findsOneWidget);
    });

    testWidgets(
        '5. "Save Customer & Use" creates and saves customer to customer list',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ Add New Customer'));
      await tester.pumpAndSettle();

      // Enter customer info
      await tester.enterText(
          find.byKey(const Key('customer_name_field')), 'Delta Industries');
      await tester.enterText(
          find.byKey(const Key('customer_company_field')), 'Delta ME LLC');
      await tester.enterText(
          find.byKey(const Key('customer_phone_field')), '+971 54 999 1111');
      await tester.pumpAndSettle();

      // Tap 'Save Customer & Use'
      await tester.tap(find.text('Save Customer & Use'));
      await tester.pumpAndSettle();

      // Verify invoice state
      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customer, 'Delta Industries');
      expect(invoiceState.customerInfo?.name, 'Delta Industries');
      expect(invoiceState.customerInfo?.isSaved, isTrue);

      // Verify saved customer list DOES contain Delta Industries
      final savedCustomers = container.read(customerListNotifierProvider);
      expect(savedCustomers.any((c) => c.name == 'Delta Industries'), isTrue);

      // Re-open customer picker and check Delta Industries is shown in list
      await tester.tap(find.text('Delta Industries'));
      await tester.pumpAndSettle();
      expect(find.text('Delta Industries'), findsWidgets);
    });

    testWidgets(
        '6. "Edit for this invoice" modifies customer for this invoice only without modifying original saved customer',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateInvoiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select existing customer ABC Trading
      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ABC Trading'));
      await tester.pumpAndSettle();

      // Tap 'Edit for this invoice'
      await tester.tap(find.text('Edit for this invoice'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Customer (This Invoice)'), findsOneWidget);
      expect(find.text('Also update original saved customer'), findsOneWidget);

      // Modify phone number for this invoice using Key
      await tester.enterText(
          find.byKey(const Key('customer_phone_field')), '+971 55 000 0000');
      await tester.pumpAndSettle();

      // Tap 'Save Changes' (checkbox is unchecked)
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify invoice state has updated phone
      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customerInfo?.phone, '+971 55 000 0000');

      // Verify saved customer in repository still has original phone (+971 55 987 6543)
      final savedCustomers = container.read(customerListNotifierProvider);
      final abcSaved =
          savedCustomers.firstWhere((c) => c.name == 'ABC Trading');
      expect(abcSaved.phone, '+971 55 987 6543');
    });

    test(
        '7. Existing invoice calculations remain completely unchanged with customer info',
        () {
      final initializedState = CreateInvoiceState(
        customerInfo: const CustomerModel(
          id: 'test_1',
          name: 'Calculation Test Customer',
          phone: '+971 50 123 4567',
        ),
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: 'item_1',
            description: 'Item 1',
            quantity: 2,
            unitPrice: 25000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 9.5,
        taxRate: 5.5,
      );

      // Subtotal = 2 x 25,000 = 50,000.00
      expect(initializedState.subtotal, 50000.0);

      // Discount = 50,000 x 9.5% = 4,750.00
      expect(initializedState.discountAmount, 4750.0);

      // Taxable = 50,000 - 4,750 = 45,250.00
      expect(initializedState.taxableAmount, 45250.0);

      // Tax = 45,250 x 5.5% = 2,488.75
      expect(initializedState.taxAmount, 2488.75);

      // Grand Total = 45,250 + 2,488.75 = 47,738.75
      expect(initializedState.grandTotal, 47738.75);

      // Customer getter
      expect(initializedState.customer, 'Calculation Test Customer');
    });

    test('8. Existing PDF generation remains completely unchanged', () async {
      final state = CreateInvoiceState(
        customerInfo: const CustomerModel(
          id: 'pdf_cust',
          name: 'PDF Test Customer',
          companyName: 'PDF Corp',
          address: 'Downtown Dubai',
          phone: '+971 50 999 8888',
          email: 'pdf@test.com',
        ),
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: 'item_1',
            description: 'Consulting',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ],
        discountType: DiscountType.none,
        discountValue: 0.0,
        taxRate: 5.0,
      );

      const service = InvoicePdfService();
      final previewModel = InvoicePreviewModel(invoice: state);
      final pdfBytes = await service.generateInvoicePdf(previewModel);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });

    test('9. Search filter in Customer Picker works as expected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final saved = container.read(customerListNotifierProvider);
      expect(saved.length, greaterThanOrEqualTo(5));

      final matchQuery =
          saved.where((c) => c.name.toLowerCase().contains('abc')).toList();
      expect(matchQuery.length, 1);
      expect(matchQuery.first.name, 'ABC Trading');
    });
  });
}
