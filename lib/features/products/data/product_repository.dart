import '../models/product_model.dart';

class ProductException implements Exception {
  final String message;
  final dynamic originalError;

  const ProductException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

abstract class ProductRepository {
  List<ProductModel> getInitialProducts();
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}
