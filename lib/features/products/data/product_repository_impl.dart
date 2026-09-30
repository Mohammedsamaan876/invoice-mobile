import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/product_model.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient? _clientOverride;
  final List<ProductModel> _memoryProducts = [];
  bool _hasFetchedFromSupabase = false;

  ProductRepositoryImpl([this._clientOverride]) {
    if (_memoryProducts.isEmpty) {
      _memoryProducts.addAll(_defaultMockProducts);
    }
  }

  SupabaseClient? get _client => _clientOverride ?? SupabaseConfig.client;

  static const List<ProductModel> _defaultMockProducts = [
    ProductModel(
      id: 'prod_1',
      name: 'Website Development',
      description: 'Full stack responsive web application development',
      unitPrice: 5000.0,
      unit: 'service',
      sku: 'SRV-WEB',
      taxRate: 5.0,
      isActive: true,
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Mobile App Development',
      description: 'Cross-platform iOS and Android mobile app development',
      unitPrice: 8000.0,
      unit: 'service',
      sku: 'SRV-MOB',
      taxRate: 5.0,
      isActive: true,
    ),
    ProductModel(
      id: 'prod_3',
      name: 'UI/UX Design',
      description: 'Figma prototypes, design systems, and wireframing',
      unitPrice: 2500.0,
      unit: 'service',
      sku: 'SRV-DES',
      taxRate: 5.0,
      isActive: true,
    ),
    ProductModel(
      id: 'prod_4',
      name: 'Maintenance',
      description: 'Monthly software updates, server monitoring, and fixes',
      unitPrice: 1500.0,
      unit: 'month',
      sku: 'SRV-MNT',
      taxRate: 5.0,
      isActive: true,
    ),
    ProductModel(
      id: 'prod_5',
      name: 'Consulting',
      description: 'Technical architecture and software engineering consulting',
      unitPrice: 3000.0,
      unit: 'hour',
      sku: 'SRV-CNS',
      taxRate: 5.0,
      isActive: true,
    ),
  ];

  @override
  List<ProductModel> getInitialProducts() =>
      List.unmodifiable(_memoryProducts);

  @override
  Future<List<ProductModel>> getProducts() async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null || user == null) {
      return List.unmodifiable(_memoryProducts);
    }

    try {
      final response = await sb
          .from('products')
          .select()
          .eq('user_id', user.id)
          .order('name', ascending: true);

      final List<dynamic> rows = response as List<dynamic>;
      final products = rows
          .map((row) =>
              ProductModel.fromSupabase(Map<String, dynamic>.from(row as Map)))
          .toList();

      _memoryProducts.clear();
      _memoryProducts.addAll(products);
      _hasFetchedFromSupabase = true;
      return List.unmodifiable(_memoryProducts);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      if (!_hasFetchedFromSupabase && _memoryProducts.isNotEmpty) {
        return List.unmodifiable(_memoryProducts);
      }
      throw _mapError(e);
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null || user == null) {
      try {
        return _memoryProducts.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }

    try {
      final response = await sb
          .from('products')
          .select()
          .eq('id', id)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        return ProductModel.fromSupabase(
            Map<String, dynamic>.from(response as Map));
      }
      return null;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (product.name.trim().isEmpty) {
      throw const ProductException('Product or service name is required.');
    }
    if (product.unitPrice < 0) {
      throw const ProductException('Unit price cannot be negative.');
    }

    if (sb == null) {
      final newProduct = product.id.isEmpty
          ? product.copyWith(id: 'prod_${DateTime.now().millisecondsSinceEpoch}')
          : product;
      _memoryProducts.removeWhere((p) => p.id == newProduct.id);
      _memoryProducts.add(newProduct);
      return newProduct;
    }

    if (user == null) {
      throw const ProductException('Please sign in to save products to the cloud.');
    }

    try {
      final payload = product.toSupabaseMap(userId: user.id);
      final response = await sb
          .from('products')
          .insert(payload)
          .select()
          .single();

      final created = ProductModel.fromSupabase(
          Map<String, dynamic>.from(response as Map));
      _memoryProducts.removeWhere((p) => p.id == created.id);
      _memoryProducts.add(created);
      return created;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (product.name.trim().isEmpty) {
      throw const ProductException('Product or service name is required.');
    }
    if (product.unitPrice < 0) {
      throw const ProductException('Unit price cannot be negative.');
    }

    if (sb == null) {
      final index = _memoryProducts.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _memoryProducts[index] = product;
      } else {
        _memoryProducts.add(product);
      }
      return product;
    }

    if (user == null) {
      throw const ProductException('Please sign in to update products in the cloud.');
    }

    try {
      final payload = product.toSupabaseMap(userId: user.id);
      final response = await sb
          .from('products')
          .update(payload)
          .eq('id', product.id)
          .eq('user_id', user.id)
          .select()
          .single();

      final updated = ProductModel.fromSupabase(
          Map<String, dynamic>.from(response as Map));
      final idx = _memoryProducts.indexWhere((p) => p.id == updated.id);
      if (idx >= 0) {
        _memoryProducts[idx] = updated;
      } else {
        _memoryProducts.add(updated);
      }
      return updated;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final sb = _client;
    final user = sb?.auth.currentUser;

    if (sb == null) {
      _memoryProducts.removeWhere((p) => p.id == id);
      return;
    }

    if (user == null) {
      throw const ProductException('Please sign in to delete products in the cloud.');
    }

    try {
      await sb
          .from('products')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
      _memoryProducts.removeWhere((p) => p.id == id);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(dynamic error) {
    if (error is ProductException) return error;
    if (error is PostgrestException) {
      if (error.code == '42501' ||
          error.message.toLowerCase().contains('policy') ||
          error.message.toLowerCase().contains('row-level security')) {
        return const ProductException(
            'Permission denied. Please ensure you are logged in.');
      }
      if (error.code == '23505') {
        return const ProductException(
            'A product with this information already exists.');
      }
      if (error.code == '23503') {
        return const ProductException(
            'This product is referenced in invoice records and cannot be deleted.');
      }
      return ProductException(
        error.message.isNotEmpty
            ? error.message
            : 'Database request failed. Please try again.',
        error,
      );
    }
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('socket') ||
        errStr.contains('network') ||
        errStr.contains('timeout') ||
        errStr.contains('clientexception')) {
      return ProductException(
        'Network error: Unable to reach database. Please check your internet connection.',
        error,
      );
    }
    return ProductException('Product operation failed: ', error);
  }
}
