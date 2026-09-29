import '../../../data/models/base_model.dart';

class CustomerModel extends BaseModel {
  final String id;
  final String name;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? taxNumber;
  final bool isSaved;

  String? get billingAddress => address;

  const CustomerModel({
    required this.id,
    required this.name,
    this.companyName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.taxNumber,
    this.isSaved = true,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    bool? isSaved,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxNumber: taxNumber ?? this.taxNumber,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final shipTo = json['ship_to'] is Map<String, dynamic>
        ? json['ship_to'] as Map<String, dynamic>
        : (json['ship_to'] is Map
            ? Map<String, dynamic>.from(json['ship_to'] as Map)
            : null);

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyName: json['company_name'] as String? ??
          json['companyName'] as String? ??
          shipTo?['company_name'] as String? ??
          shipTo?['companyName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String? ??
          json['billing_address'] as String? ??
          shipTo?['address'] as String?,
      city: json['city'] as String? ?? shipTo?['city'] as String?,
      country: json['country'] as String? ?? shipTo?['country'] as String?,
      taxNumber: json['tax_number'] as String? ??
          json['taxNumber'] as String? ??
          shipTo?['tax_number'] as String? ??
          shipTo?['taxNumber'] as String?,
      isSaved: json['is_saved'] as bool? ?? true,
    );
  }

  factory CustomerModel.fromSupabase(Map<String, dynamic> map) =>
      CustomerModel.fromJson(map);

  Map<String, dynamic> toSupabaseMap({required String userId}) {
    final shipTo = <String, dynamic>{};
    if (companyName != null && companyName!.trim().isNotEmpty) {
      shipTo['company_name'] = companyName!.trim();
    }
    if (taxNumber != null && taxNumber!.trim().isNotEmpty) {
      shipTo['tax_number'] = taxNumber!.trim();
    }

    final map = <String, dynamic>{
      'user_id': userId,
      'name': name.trim(),
      'address': address?.trim() ?? '',
      'city': city?.trim() ?? '',
      'country': country?.trim() ?? '',
      'phone': phone?.trim() ?? '',
      'email': email?.trim() ?? '',
      'ship_to': shipTo,
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
      if (companyName != null) 'company_name': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (taxNumber != null) 'tax_number': taxNumber,
      'is_saved': isSaved,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          companyName == other.companyName &&
          email == other.email &&
          phone == other.phone &&
          address == other.address &&
          city == other.city &&
          country == other.country &&
          taxNumber == other.taxNumber &&
          isSaved == other.isSaved;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      (companyName?.hashCode ?? 0) ^
      (email?.hashCode ?? 0) ^
      (phone?.hashCode ?? 0) ^
      (address?.hashCode ?? 0) ^
      (city?.hashCode ?? 0) ^
      (country?.hashCode ?? 0) ^
      (taxNumber?.hashCode ?? 0) ^
      isSaved.hashCode;
}
