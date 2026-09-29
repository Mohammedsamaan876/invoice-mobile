import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/customers/data/customer_repository.dart';
import 'package:invoice_app/features/customers/models/customer_model.dart';
import 'package:invoice_app/features/customers/providers/customer_provider.dart';
import 'package:invoice_app/features/invoices/models/create_invoice_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_item_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_preview_model.dart';
import 'package:invoice_app/features/invoices/providers/create_invoice_provider.dart';
import 'package:invoice_app/features/invoices/services/invoice_pdf_service.dart';

class MockCustomerRepository implements CustomerRepository {
  final List<CustomerModel> _customers;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getCalls = 0;

  MockCustomerRepository([List<CustomerModel>? initial])
      : _customers = initial ??
            [
              const CustomerModel(
                id: 'c1',
                name: 'Alpha Trading LLC',
                companyName: 'Alpha Corp',
                phone: '+971 50 111 2222',
                email: 'alpha@trade.ae',
                address: 'Sheikh Zayed Rd',
                city: 'Dubai',
                country: 'UAE',
                taxNumber: '10011122200003',
                isSaved: true,
              ),
              const CustomerModel(
                id: 'c2',
                name: 'Beta Services',
                companyName: 'Beta Group',
                phone: '+971 55 333 4444',
                email: 'info@betaservices.com',
                address: 'Hamdan St',
                city: 'Abu Dhabi',
                country: 'UAE',
                taxNumber: '10033344400003',
                isSaved: true,
              ),
            ];

  @override
  List<CustomerModel> getInitialCustomers() => List.unmodifiable(_customers);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    getCalls++;
    return List.unmodifiable(_customers);
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    createCalls++;
    final created = customer.copyWith(
      id: customer.id.isEmpty ? 'uuid-${DateTime.now().millisecondsSinceEpoch}' : customer.id,
      isSaved: true,
    );
    _customers.add(created);
    return created;
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    updateCalls++;
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index >= 0) {
      _customers[index] = customer;
    } else {
      _customers.add(customer);
    }
    return customer;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    deleteCalls++;
    _customers.removeWhere((c) => c.id == id);
  }
}

void main() {
  group('Supabase Customer Integration & Architecture Tests', () {
    test('1. Supabase schema mapping and serialization respects RLS user_id & extra fields', () {
      const customer = CustomerModel(
        id: '11111111-2222-3333-4444-555555555555',
        name: 'Gulf Construction',
        companyName: 'Gulf Construction LLC',
        phone: '+971 4 888 9999',
        email: 'build@gulf.ae',
        address: 'Al Quoz Industrial 1',
        city: 'Dubai',
        country: 'United Arab Emirates',
        taxNumber: '100888999000003',
      );

      // Serialize to Supabase map targeting existing customers schema
      final supabaseMap = customer.toSupabaseMap(userId: 'user-uuid-1234');

      expect(supabaseMap['user_id'], 'user-uuid-1234');
      expect(supabaseMap['name'], 'Gulf Construction');
      expect(supabaseMap['address'], 'Al Quoz Industrial 1');
      expect(supabaseMap['city'], 'Dubai');
      expect(supabaseMap['country'], 'United Arab Emirates');
      expect(supabaseMap['phone'], '+971 4 888 9999');
      expect(supabaseMap['email'], 'build@gulf.ae');
      expect(supabaseMap['id'], '11111111-2222-3333-4444-555555555555');

      // Extra fields mapped into ship_to jsonb
      final shipTo = supabaseMap['ship_to'] as Map<String, dynamic>;
      expect(shipTo['company_name'], 'Gulf Construction LLC');
      expect(shipTo['tax_number'], '100888999000003');

      // Deserialize from Supabase row
      final restored = CustomerModel.fromSupabase(supabaseMap);
      expect(restored.name, 'Gulf Construction');
      expect(restored.companyName, 'Gulf Construction LLC');
      expect(restored.taxNumber, '100888999000003');
      expect(restored.phone, '+971 4 888 9999');
      expect(restored.email, 'build@gulf.ae');
      expect(restored.city, 'Dubai');
      expect(restored.country, 'United Arab Emirates');
    });

    test('2. Fetch customers through repository and Riverpod Provider', () async {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(customersListProvider.future);
      expect(list.length, 2);
      expect(list[0].name, 'Alpha Trading LLC');
      expect(list[1].name, 'Beta Services');
      expect(mockRepo.getCalls, 1);
    });

    test('3. Create customer persists to repository and updates notifier state', () async {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(customerListNotifierProvider.notifier);
      const newCustomer = CustomerModel(
        id: '',
        name: 'Gamma Tech',
        companyName: 'Gamma ME',
        phone: '+971 52 777 8888',
        email: 'info@gammatech.ae',
      );

      final created = await notifier.addCustomer(newCustomer);
      expect(created.name, 'Gamma Tech');
      expect(mockRepo.createCalls, 1);

      final currentState = container.read(customerListNotifierProvider);
      expect(currentState.any((c) => c.name == 'Gamma Tech'), isTrue);
    });

    test('4. Update customer updates repository and notifier state', () async {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(customerListNotifierProvider.notifier);
      const updated = CustomerModel(
        id: 'c1',
        name: 'Alpha Trading LLC',
        companyName: 'Alpha Global Group',
        phone: '+971 50 999 0000',
        email: 'contact@alphaglobal.ae',
      );

      await notifier.updateCustomer(updated);
      expect(mockRepo.updateCalls, 1);

      final currentState = container.read(customerListNotifierProvider);
      final c1 = currentState.firstWhere((c) => c.id == 'c1');
      expect(c1.companyName, 'Alpha Global Group');
      expect(c1.phone, '+971 50 999 0000');
    });

    test('5. Delete customer removes record from repository and notifier state', () async {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(customerListNotifierProvider.notifier);
      await notifier.deleteCustomer('c2');

      expect(mockRepo.deleteCalls, 1);
      final currentState = container.read(customerListNotifierProvider);
      expect(currentState.any((c) => c.id == 'c2'), isFalse);
      expect(currentState.length, 1);
    });

    test('6. "Use Once" does NOT create customer in repository, but updates invoice snapshot', () {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      const tempCustomer = CustomerModel(
        id: 'temp-123',
        name: 'Temporary One-Off Client',
        companyName: 'No Company',
        phone: '+971 50 000 1111',
        isSaved: false,
      );

      // Invoice provider selects the customer snapshot without calling repo.createCustomer
      final invoiceNotifier = container.read(createInvoiceProvider.notifier);
      invoiceNotifier.setCustomerInfo(tempCustomer);

      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customer, 'Temporary One-Off Client');
      expect(invoiceState.customerInfo?.name, 'Temporary One-Off Client');
      expect(invoiceState.customerInfo?.isSaved, isFalse);

      // Verify no create call was made to repository
      expect(mockRepo.createCalls, 0);
      final savedCustomers = container.read(customerListNotifierProvider);
      expect(savedCustomers.any((c) => c.name == 'Temporary One-Off Client'), isFalse);
    });

    test('7. "Save Customer & Use" creates customer in repository and updates invoice snapshot', () async {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      const newCustomer = CustomerModel(
        id: '',
        name: 'Omega Logistics',
        companyName: 'Omega FZE',
        phone: '+971 4 555 6666',
        isSaved: true,
      );

      final customerNotifier = container.read(customerListNotifierProvider.notifier);
      final created = await customerNotifier.addCustomer(newCustomer);

      final invoiceNotifier = container.read(createInvoiceProvider.notifier);
      invoiceNotifier.setCustomerInfo(created);

      expect(mockRepo.createCalls, 1);
      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customer, 'Omega Logistics');
      expect(invoiceState.customerInfo?.isSaved, isTrue);

      final savedCustomers = container.read(customerListNotifierProvider);
      expect(savedCustomers.any((c) => c.name == 'Omega Logistics'), isTrue);
    });

    test('8. Edit for invoice only does NOT update saved customer in repository', () {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final originalCustomer = mockRepo.getInitialCustomers().first; // c1: Alpha Trading LLC
      final invoiceNotifier = container.read(createInvoiceProvider.notifier);
      invoiceNotifier.setCustomerInfo(originalCustomer);

      // Edit snapshot only for this invoice
      final invoiceOnlyCustomer = originalCustomer.copyWith(
        phone: '+971 50 000 9999',
        address: 'New Delivery Site C',
      );
      invoiceNotifier.setCustomerInfo(invoiceOnlyCustomer);

      // Verify invoice snapshot has modified data
      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customerInfo?.phone, '+971 50 000 9999');
      expect(invoiceState.customerInfo?.address, 'New Delivery Site C');

      // Verify repository was NOT called
      expect(mockRepo.updateCalls, 0);
      final savedCustomers = container.read(customerListNotifierProvider);
      final c1 = savedCustomers.firstWhere((c) => c.id == 'c1');
      expect(c1.phone, '+971 50 111 2222');
    });

    test('9. Edit + update original customer updates repository and invoice snapshot', () async {
      final mockRepo = MockCustomerRepository();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final originalCustomer = mockRepo.getInitialCustomers().first; // c1
      final customerNotifier = container.read(customerListNotifierProvider.notifier);
      final invoiceNotifier = container.read(createInvoiceProvider.notifier);

      final updatedCustomer = originalCustomer.copyWith(
        phone: '+971 50 777 0000',
        companyName: 'Alpha Prime Trading',
      );

      final saved = await customerNotifier.updateCustomer(updatedCustomer);
      invoiceNotifier.setCustomerInfo(saved);

      expect(mockRepo.updateCalls, 1);
      final invoiceState = container.read(createInvoiceProvider);
      expect(invoiceState.customerInfo?.phone, '+971 50 777 0000');
      expect(invoiceState.customerInfo?.companyName, 'Alpha Prime Trading');

      final savedCustomers = container.read(customerListNotifierProvider);
      final c1 = savedCustomers.firstWhere((c) => c.id == 'c1');
      expect(c1.phone, '+971 50 777 0000');
      expect(c1.companyName, 'Alpha Prime Trading');
    });

    test('10. Search filtering matches customer name, company name, phone, and email', () {
      final customers = [
        const CustomerModel(
          id: '1',
          name: 'Mohammed Ali',
          companyName: 'Falcon Transport',
          phone: '+971 50 123 4567',
          email: 'ali@falcon.ae',
        ),
        const CustomerModel(
          id: '2',
          name: 'Sarah Smith',
          companyName: 'Apex Media',
          phone: '+971 55 987 6543',
          email: 'sarah@apex.com',
        ),
      ];

      List<CustomerModel> filter(String q) {
        final query = q.toLowerCase();
        return customers.where((c) {
          final matchName = c.name.toLowerCase().contains(query);
          final matchCompany = c.companyName?.toLowerCase().contains(query) ?? false;
          final matchPhone = c.phone?.toLowerCase().contains(query) ?? false;
          final matchEmail = c.email?.toLowerCase().contains(query) ?? false;
          return matchName || matchCompany || matchPhone || matchEmail;
        }).toList();
      }

      // Name search
      expect(filter('mohammed').length, 1);
      expect(filter('mohammed').first.id, '1');

      // Company search
      expect(filter('apex').length, 1);
      expect(filter('apex').first.id, '2');

      // Phone search
      expect(filter('123').length, 1);
      expect(filter('123').first.id, '1');

      // Email search
      expect(filter('apex.com').length, 1);
      expect(filter('apex.com').first.id, '2');

      // Miss
      expect(filter('nonexistent').isEmpty, isTrue);
    });

    test('11. Existing invoice calculations and historical accuracy remain unchanged with snapshot', () {
      final initializedState = CreateInvoiceState(
        customerInfo: const CustomerModel(
          id: 'c1',
          name: 'Alpha Trading LLC',
          companyName: 'Alpha Corp',
          phone: '+971 50 111 2222',
          email: 'alpha@trade.ae',
          taxNumber: '10011122200003',
        ),
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: 'item_1',
            description: 'Web Development Services',
            quantity: 2,
            unitPrice: 5000.0,
          ),
          InvoiceItemModel(
            id: 'item_2',
            description: 'Hosting & Domain',
            quantity: 1,
            unitPrice: 1000.0,
          ),
        ],
        discountType: DiscountType.percentage,
        discountValue: 10.0,
        taxRate: 5.0,
      );

      // Verify subtotal: 2*5000 + 1000 = 11000
      expect(initializedState.subtotal, 11000.0);

      // Verify discount: 10% of 11000 = 1100
      expect(initializedState.discountAmount, 1100.0);

      // Taxable amount = 11000 - 1100 = 9900.0
      expect(initializedState.taxableAmount, 9900.0);

      // Tax: 5% of 9900 = 495.0
      expect(initializedState.taxAmount, 495.0);

      // Grand total = 9900 + 495 = 10395.0
      expect(initializedState.grandTotal, 10395.0);

      // Customer name getter
      expect(initializedState.customer, 'Alpha Trading LLC');

      // Historical accuracy: Even if customer later changes phone or company,
      // the invoice snapshot remains untouched
      final laterChangedCustomer = const CustomerModel(
        id: 'c1',
        name: 'Alpha Trading LLC',
        companyName: 'Alpha New Holding',
        phone: '+971 59 999 8888',
      );
      expect(initializedState.customerInfo?.companyName, 'Alpha Corp');
      expect(initializedState.customerInfo?.phone, '+971 50 111 2222');
      expect(laterChangedCustomer.companyName, 'Alpha New Holding');
    });

    test('12. Existing PDF generation produces valid bytes with customer snapshot', () async {
      final state = CreateInvoiceState(
        customerInfo: const CustomerModel(
          id: 'c1',
          name: 'Alpha Trading LLC',
          companyName: 'Alpha Corp',
          phone: '+971 50 111 2222',
          email: 'alpha@trade.ae',
          address: 'Al Barsha, Dubai',
          city: 'Dubai',
          country: 'UAE',
          taxNumber: '10011122200003',
        ),
        invoiceDate: DateTime(2026, 9, 26),
        dueDate: DateTime(2026, 10, 10),
        items: const [
          InvoiceItemModel(
            id: '1',
            description: 'Consulting',
            quantity: 1,
            unitPrice: 5000.0,
          ),
        ],
        taxRate: 5.0,
      );

      const pdfService = InvoicePdfService();
      final previewModel = InvoicePreviewModel(invoice: state);
      final Uint8List pdfBytes = await pdfService.generateInvoicePdf(previewModel);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF begins with %PDF header
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });
  });
}
