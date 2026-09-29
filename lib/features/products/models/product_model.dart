import '../../../data/models/base_model.dart';

class ProductModel extends BaseModel {
  final String id;
  final String name;
  final String? description;
  final double unitPrice;
  final String unit;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.unitPrice,
    this.unit = 'unit',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'unit',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit_price': unitPrice,
      'unit': unit,
    };
  }
}
