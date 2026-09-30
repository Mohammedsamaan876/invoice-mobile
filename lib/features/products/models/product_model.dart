import '../../../data/models/base_model.dart';

class ProductModel extends BaseModel {
  final String id;
  final String name;
  final String? description;
  final double unitPrice;
  final String unit;
  final String? sku;
  final double? taxRate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.unitPrice,
    this.unit = 'unit',
    this.sku,
    this.taxRate = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? unitPrice,
    String? unit,
    String? sku,
    double? taxRate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      sku: sku ?? this.sku,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description'] as String?,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ??
          (json['rate'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      unit: json['unit'] as String? ?? 'unit',
      sku: json['sku'] as String?,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  factory ProductModel.fromSupabase(Map<String, dynamic> map) =>
      ProductModel.fromJson(map);

  Map<String, dynamic> toSupabaseMap({required String userId}) {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name.trim(),
      'description': description?.trim(),
      'unit_price': unitPrice,
      'unit': unit.trim().isNotEmpty ? unit.trim() : 'unit',
      'sku': sku?.trim(),
      'tax_rate': taxRate ?? 0.0,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(id);
    if (isUuid) {
      map['id'] = id;
    }
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'unit_price': unitPrice,
      'unit': unit,
      if (sku != null) 'sku': sku,
      if (taxRate != null) 'tax_rate': taxRate,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          unitPrice == other.unitPrice &&
          unit == other.unit &&
          sku == other.sku &&
          taxRate == other.taxRate &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      (description?.hashCode ?? 0) ^
      unitPrice.hashCode ^
      unit.hashCode ^
      (sku?.hashCode ?? 0) ^
      (taxRate?.hashCode ?? 0) ^
      isActive.hashCode;
}
