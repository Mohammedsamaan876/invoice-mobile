import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/product_repository.dart';
import '../data/product_repository_impl.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

class ProductListNotifier extends Notifier<List<ProductModel>> {
  @override
  List<ProductModel> build() {
    final repo = ref.watch(productRepositoryProvider);

    ref.listen(currentUserProvider, (prev, next) {
      if (prev?.id != next?.id) {
        loadProducts();
      }
    });

    return repo.getInitialProducts();
  }

  Future<List<ProductModel>> loadProducts() async {
    final repo = ref.read(productRepositoryProvider);
    try {
      final products = await repo.getProducts();
      state = products;
      return products;
    } catch (_) {
      return state;
    }
  }

  void setProducts(List<ProductModel> products) {
    state = products;
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final repo = ref.read(productRepositoryProvider);
    final created = await repo.createProduct(product);
    state = [...state.where((p) => p.id != created.id), created];
    ref.invalidate(productsListProvider);
    return created;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final repo = ref.read(productRepositoryProvider);
    final updated = await repo.updateProduct(product);
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
    ref.invalidate(productsListProvider);
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    final repo = ref.read(productRepositoryProvider);
    await repo.deleteProduct(id);
    state = state.where((p) => p.id != id).toList();
    ref.invalidate(productsListProvider);
  }
}

final productListNotifierProvider =
    NotifierProvider<ProductListNotifier, List<ProductModel>>(
  ProductListNotifier.new,
);

final productsListProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final products = await repo.getProducts();
  ref.read(productListNotifierProvider.notifier).setProducts(products);
  return products;
});
