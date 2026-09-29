import 'product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl();

  @override
  Future<List<ProductModel>> getProducts() async {
    return [];
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    return null;
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {}
}
