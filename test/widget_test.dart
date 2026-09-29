import 'package:invoice_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_app/main.dart';
import 'package:invoice_app/features/invoices/presentation/screens/invoice_list_screen.dart';
import 'package:invoice_app/features/invoices/presentation/widgets/invoice_list_card.dart';

void main() {
  group('Dashboard Tests', () {
    testWidgets('Dashboard UI smoke and interaction test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: InvoiceApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Top app bar header
      expect(find.text('Good morning 👋'), findsOneWidget);
      expect(find.text('Manage your invoices with ease'), findsOneWidget);

      // Primary action button
      expect(find.text('+ Create Invoice'), findsOneWidget);

      // Summary statistics cards
      expect(find.text('Total Invoices'), findsOneWidget);
      expect(find.text('124'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('AED 48,250'), findsOneWidget);

      // Recent invoices section
      expect(find.text('Recent Invoices'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);

      // Bottom navigation
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Tap + Create Invoice button -> navigates to Create Invoice
      await tester.tap(find.text('+ Create Invoice'));
      await tester.pumpAndSettle();
      expect(find.text('Create Invoice'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Tap Customers navigation destination -> SnackBar
      await tester.tap(find.text('Customers'));
      await tester.pump();
      expect(find.text('Coming soon'), findsOneWidget);

      // Tap Invoices navigation destination -> navigates to Invoices
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();
      expect(find.text('Manage and track your invoices'), findsOneWidget);
    });

    for (final width in [360.0, 390.0, 412.0]) {
      testWidgets('Dashboard renders with no overflow on width: ${width}px',
          (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: InvoiceApp(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Good morning 👋'), findsOneWidget);
        expect(find.text('+ Create Invoice'), findsOneWidget);
        expect(find.text('Total Invoices'), findsOneWidget);
        expect(find.text('Recent Invoices'), findsOneWidget);
      });
    }
  });

  group('Invoice List Screen Tests', () {
    testWidgets('Invoice List screen renders all core elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvoiceListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Invoices'), findsWidgets);
      expect(find.text('Manage and track your invoices'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);

      // Search bar
      expect(find.text('Search invoices...'), findsOneWidget);

      // Filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Partial'), findsOneWidget);

      // Sample mock invoices
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);
      expect(find.text('INV-002'), findsOneWidget);
      expect(find.text('ABC Trading'), findsOneWidget);
      expect(find.text('INV-003'), findsOneWidget);
      expect(find.text('XYZ LLC'), findsOneWidget);
    });

    testWidgets('Search works by customer name and invoice number',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvoiceListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial list shows INV-001 and INV-002
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('INV-002'), findsOneWidget);

      // Search for ZAHURUDDIN
      await tester.enterText(find.byType(TextField), 'ZAHUR');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InvoiceListCard, 'INV-001'), findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsOneWidget);
      expect(find.text('INV-002'), findsNothing);
      expect(find.text('ABC Trading'), findsNothing);

      // Search for INV-004
      await tester.enterText(find.byType(TextField), 'INV-004');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InvoiceListCard, 'INV-004'), findsOneWidget);
      expect(find.text('Global Electronics'), findsOneWidget);
      expect(find.text('ZAHURUDDIN'), findsNothing);
    });

    testWidgets('Filter chips filter invoices by status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvoiceListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Paid chip
      await tester.tap(find.text('Paid'));
      await tester.pumpAndSettle();

      expect(find.text('INV-001'), findsOneWidget); // PAID
      expect(find.text('INV-003'), findsOneWidget); // PAID
      expect(find.text('INV-002'), findsNothing); // PENDING
      expect(find.text('INV-006'), findsNothing); // PARTIAL

      // Tap Pending chip
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      expect(find.text('INV-002'), findsOneWidget); // PENDING
      expect(find.text('INV-004'), findsOneWidget); // PENDING
      expect(find.text('INV-001'), findsNothing); // PAID

      // Tap Partial chip
      await tester.tap(find.text('Partial'));
      await tester.pumpAndSettle();

      expect(find.text('INV-006'), findsOneWidget); // PARTIAL
      expect(find.text('INV-009'), findsOneWidget); // PARTIAL
      expect(find.text('INV-001'), findsNothing); // PAID
      expect(find.text('INV-002'), findsNothing); // PENDING

      // Tap All chip
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('INV-002'), findsOneWidget);
    });

    testWidgets('Empty state appears when no search results match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvoiceListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'NonExistentInvoice999');
      await tester.pumpAndSettle();

      expect(find.text('No invoices found'), findsOneWidget);
      expect(find.text('Try changing your search or filter.'), findsOneWidget);
    });

    testWidgets('Tapping invoice card shows SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvoiceListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('INV-001'));
      await tester.pump();

      expect(find.text('Invoice details coming soon'), findsOneWidget);
    });

    testWidgets('Tapping create action button in header navigates to Create Invoice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvoiceListScreen(),
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      expect(find.text('Create Invoice'), findsOneWidget);
    });

    for (final width in [360.0, 390.0, 412.0]) {
      testWidgets(
          'Invoice List screen renders with no overflow on width: ${width}px',
          (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: InvoiceListScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Manage and track your invoices'), findsOneWidget);
        expect(find.text('Search invoices...'), findsOneWidget);
        expect(find.text('INV-001'), findsOneWidget);
      });
    }
  });
}
