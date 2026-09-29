import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}
