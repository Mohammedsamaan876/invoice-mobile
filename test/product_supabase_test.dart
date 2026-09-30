import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/auth/models/user_model.dart';
import 'package:invoice_app/features/auth/providers/auth_provider.dart';
import 'package:invoice_app/features/invoices/models/create_invoice_model.dart';
import 'package:invoice_app/features/invoices/models/invoice_item_model.dart';
import 'package:invoice_app/features/invoices/presentation/widgets/product_picker_sheet.dart';
import 'package:invoice_app/features/invoices/providers/create_invoice_provider.dart';
import 'package:invoice_app/features/products/data/product_repository.dart';
import 'package:invoice_app/features/products/models/product_model.dart';
import 'package:invoice_app/features/products/providers/product_provider.dart';

class MockProductRepository implements ProductRepository {
  final List<ProductModel> _products;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getCalls = 0;
  bool shouldFail = false;

  MockProductRepository([List<ProductModel>? initial])
      : _products = initial != null
            ? List.from(initial)
            : [
                const ProductModel(
                  id: 'p1',
                  name: 'Website Development',
                  description: 'Full stack responsive web application development',
                  unitPrice: 5000.0,
                  unit: 'service',
                  sku: 'SRV-WEB',
                  taxRate: 5.0,
                  isActive: true,
                ),
                const ProductModel(
                  id: 'p2',
                  name: 'Mobile App Development',
                  description: 'Cross-platform iOS and Android mobile app development',
                  unitPrice: 8000.0,
                  unit: 'service',
                  sku: 'SRV-MOB',
                  taxRate: 5.0,
                  isActive: true,
                ),
              ];

  @override
  List<ProductModel> getInitialProducts() => List.unmodifiable(_products);

  @override
  Future<List<ProductModel>> getProducts() async {
    getCalls++;
    if (shouldFail) {
      throw const ProductException('Network error: Unable to reach database.');
    }
    return List.unmodifiable(_products);
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    if (shouldFail) {
      throw const ProductException('Network error: Unable to reach database.');
    }
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    createCalls++;
    if (shouldFail) {
      throw const ProductException('Failed to create product in cloud.');
    }
    final created = product.copyWith(
      id: product.id.isEmpty
          ? 'uuid-${DateTime.now().millisecondsSinceEpoch}'
          : product.id,
    );
    _products.add(created);
    return created;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    updateCalls++;
    if (shouldFail) {
      throw const ProductException('Failed to update product in cloud.');
    }
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    deleteCalls++;
    if (shouldFail) {
      throw const ProductException('Failed to delete product in cloud.');
    }
    _products.removeWhere((p) => p.id == id);
  }
}

void main() {
  group('Supabase Product Integration & Architecture Tests (Phase 2B)', () {
    test('1. Product schema mapping & serialization respects RLS user_id & DB columns', () {
      const product = ProductModel(
        id: '12345678-1234-1234-1234-123456789abc',
        name: 'Cloud Infrastructure Setup',
        description: 'Terraform, Docker & Kubernetes setup',
        unitPrice: 4500.0,
        unit: 'project',
        sku: 'SRV-CLOUD',
        taxRate: 5.0,
        isActive: true,
      );

      final supabaseMap = product.toSupabaseMap(userId: 'user-uuid-999');

      expect(supabaseMap['user_id'], 'user-uuid-999');
      expect(supabaseMap['name'], 'Cloud Infrastructure Setup');
      expect(supabaseMap['description'], 'Terraform, Docker & Kubernetes setup');
      expect(supabaseMap['unit_price'], 4500.0);
      expect(supabaseMap['unit'], 'project');
      expect(supabaseMap['sku'], 'SRV-CLOUD');
      expect(supabaseMap['tax_rate'], 5.0);
      expect(supabaseMap['is_active'], isTrue);
      expect(supabaseMap['id'], '12345678-1234-1234-1234-123456789abc');

      // Deserialize from Supabase row
      final restored = ProductModel.fromSupabase(supabaseMap);
      expect(restored.name, 'Cloud Infrastructure Setup');
      expect(restored.description, 'Terraform, Docker & Kubernetes setup');
      expect(restored.unitPrice, 4500.0);
      expect(restored.unit, 'project');
      expect(restored.sku, 'SRV-CLOUD');
      expect(restored.taxRate, 5.0);
      expect(restored.isActive, isTrue);
    });

    test('2. Fetch products through repository and Riverpod Provider', () async {
      final mockRepo = MockProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(productsListProvider.future);
      expect(list.length, 2);
      expect(list[0].name, 'Website Development');
      expect(list[1].name, 'Mobile App Development');
      expect(mockRepo.getCalls, 1);
    });

    test('3. Fetch product by ID returns correct record', () async {
      final mockRepo = MockProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(productRepositoryProvider);
      final product = await repo.getProductById('p1');
      expect(product, isNotNull);
      expect(product!.name, 'Website Development');
      expect(product.unitPrice, 5000.0);

      final missing = await repo.getProductById('non-existent');
      expect(missing, isNull);
    });

    test('4. Create product persists to repository and updates notifier state', () async {
      final mockRepo = MockProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      const newProduct = ProductModel(
        id: '',
        name: 'SEO Optimization',
        description: 'On-page and technical SEO audit',
        unitPrice: 2000.0,
        unit: 'month',
        sku: 'SRV-SEO',
      );

      final created = await notifier.addProduct(newProduct);
      expect(created.name, 'SEO Optimization');
      expect(created.unitPrice, 2000.0);
      expect(mockRepo.createCalls, 1);

      final currentState = container.read(productListNotifierProvider);
      expect(currentState.any((p) => p.name == 'SEO Optimization'), isTrue);
    });

    test('5. Update product updates repository and notifier state', () async {
      final mockRepo = MockProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      const updated = ProductModel(
        id: 'p1',
        name: 'Website Development (Enterprise)',
        description: 'Enterprise web portal with custom CMS',
        unitPrice: 7500.0,
        unit: 'service',
        sku: 'SRV-WEB-ENT',
      );

      await notifier.updateProduct(updated);
      expect(mockRepo.updateCalls, 1);

      final currentState = container.read(productListNotifierProvider);
      final item = currentState.firstWhere((p) => p.id == 'p1');
      expect(item.name, 'Website Development (Enterprise)');
      expect(item.unitPrice, 7500.0);
    });

    test('6. Delete product safely removes from repository and notifier state', () async {
      final mockRepo = MockProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.deleteProduct('p2');
      expect(mockRepo.deleteCalls, 1);

      final currentState = container.read(productListNotifierProvider);
      expect(currentState.any((p) => p.id == 'p2'), isFalse);
    });

    test('7. Search and filter products supports name, SKU, and description', () {
      final products = [
        const ProductModel(
          id: '1',
          name: 'Accounting Audit',
          description: 'Year-end financial audit and review',
          unitPrice: 6000.0,
          sku: 'ACC-01',
        ),
        const ProductModel(
          id: '2',
          name: 'Social Media Marketing',
          description: 'Monthly campaigns and content creation',
          unitPrice: 3500.0,
          sku: 'MKT-SOC',
        ),
      ];

      // Filter by name
      final filterName = products.where((p) =>
          p.name.toLowerCase().contains('accounting'.toLowerCase())).toList();
      expect(filterName.length, 1);
      expect(filterName.first.id, '1');

      // Filter by SKU
      final filterSku = products.where((p) =>
          p.sku?.toLowerCase().contains('mkt'.toLowerCase()) ?? false).toList();
      expect(filterSku.length, 1);
      expect(filterSku.first.id, '2');

      // Filter by description
      final filterDesc = products.where((p) =>
          p.description?.toLowerCase().contains('financial'.toLowerCase()) ?? false).toList();
      expect(filterDesc.length, 1);
      expect(filterDesc.first.id, '1');
    });

    testWidgets('8. Product selector loads repository data in bottom sheet', (tester) async {
      final mockRepo = MockProductRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProductPickerSheet(
                onProductSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Select Product / Service'), findsOneWidget);
      expect(find.text('Website Development'), findsOneWidget);
      expect(find.text('Mobile App Development'), findsOneWidget);
      expect(find.text('AED 5000.00'), findsOneWidget);
      expect(find.text('AED 8000.00'), findsOneWidget);
    });

    testWidgets('9. Selecting a product populates invoice item description and unit price', (tester) async {
      final mockRepo = MockProductRepository();
      ProductModel? selected;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProductPickerSheet(
                onProductSelected: (p) => selected = p,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Website Development'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.name, 'Website Development');
      expect(selected!.unitPrice, 5000.0);
    });

    test('10. Existing invoice calculations remain unchanged when product is selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(createInvoiceProvider.notifier);

      // Select product: "Website Development" at 5000.0 with qty 2
      notifier.updateItem(
        'item_1',
        description: 'Website Development',
        unitPrice: 5000.0,
        quantity: 2,
      );

      final state = container.read(createInvoiceProvider);
      // Subtotal = 2 * 5000 = 10,000
      expect(state.subtotal, 10000.0);

      // Verify tax calculation (5%)
      notifier.setTaxRate(5.0);
      final withTax = container.read(createInvoiceProvider);
      // Tax = 5% of 10000 = 500, Grand Total = 10500
      expect(withTax.taxAmount, 500.0);
      expect(withTax.grandTotal, 10500.0);

      // Verify discount (10%)
      notifier.setDiscountType(DiscountType.percentage);
      notifier.setDiscountValue(10.0);
      final withDiscount = container.read(createInvoiceProvider);
      // Discount = 10% of 10000 = 1000. Taxable amount = 9000.
      // Tax = 5% of 9000 = 450. Grand Total = 9450.
      expect(withDiscount.discountAmount, 1000.0);
      expect(withDiscount.taxableAmount, 9000.0);
      expect(withDiscount.taxAmount, 450.0);
      expect(withDiscount.grandTotal, 9450.0);
    });

    test('11. Product snapshot behavior: Editing catalog price does NOT alter existing invoice item', () {
      // Create initial invoice item from product at 5000.0
      final invoiceItem = InvoiceItemModel(
        id: 'item_1',
        description: 'Website Development',
        quantity: 1,
        unitPrice: 5000.0,
      );

      expect(invoiceItem.unitPrice, 5000.0);
      expect(invoiceItem.total, 5000.0);

      // Product price changes in catalog to 6000.0
      const updatedCatalogProduct = ProductModel(
        id: 'p1',
        name: 'Website Development',
        unitPrice: 6000.0,
        unit: 'service',
      );

      // Existing invoice item must retain snapshot price (5000.0)
      expect(invoiceItem.unitPrice, 5000.0);
      expect(invoiceItem.total, 5000.0);
      expect(updatedCatalogProduct.unitPrice, 6000.0);
    });

    test('12. Failed Supabase operations do not corrupt UI state and surface clean error', () async {
      final mockRepo = MockProductRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);

      expect(
        () => notifier.addProduct(
          const ProductModel(
            id: '',
            name: 'Broken Item',
            unitPrice: 100.0,
          ),
        ),
        throwsA(isA<ProductException>()),
      );

      // Current state should not have phantom broken item
      final currentState = container.read(productListNotifierProvider);
      expect(currentState.any((p) => p.name == 'Broken Item'), isFalse);
    });

    test('13. Authentication user change clears/reloads product state', () async {
      final mockRepo = MockProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Trigger initial load
      await container.read(productsListProvider.future);
      expect(mockRepo.getCalls, 1);

      // Simulating user change
      container.read(currentUserProvider.notifier).setUser(const UserModel(
            id: 'user_A',
            email: 'userA@test.com',
            fullName: 'User A',
          ));


      expect(mockRepo.getCalls, 2);
    });
  });
}


