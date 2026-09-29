import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../data/models/base_model.dart';

class UserModel extends BaseModel {
  final String id;
  final String email;
  final String? fullName;
  final String? companyName;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.companyName,
    this.createdAt,
  });

  factory UserModel.fromSupabaseUser(sb.User user) {
    final meta = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: (meta['full_name'] ?? meta['fullName']) as String?,
      companyName: (meta['company_name'] ?? meta['companyName']) as String?,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      companyName: json['company_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'company_name': companyName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? companyName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
