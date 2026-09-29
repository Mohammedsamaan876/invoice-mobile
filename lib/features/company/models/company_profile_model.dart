import '../../../data/models/base_model.dart';

class CompanyProfileModel extends BaseModel {
  final String id;
  final String companyName;
  final String? taxId;
  final String? email;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String? signatureUrl;

  const CompanyProfileModel({
    required this.id,
    required this.companyName,
    this.taxId,
    this.email,
    this.phone,
    this.address,
    this.logoUrl,
    this.signatureUrl,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      id: json['id'] as String,
      companyName: json['company_name'] as String,
      taxId: json['tax_id'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'tax_id': taxId,
      'email': email,
      'phone': phone,
      'address': address,
      'logo_url': logoUrl,
      'signature_url': signatureUrl,
    };
  }
}
