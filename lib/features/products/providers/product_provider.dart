import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../data/product_repository_impl.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepositoryImpl();
});

final productsListProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});
