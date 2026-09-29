import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient? client;
  UserModel? _mockUser;

  AuthRepositoryImpl({this.client});

  @override
  UserModel? getCurrentUser() {
    final sb = client;
    if (sb == null) return _mockUser;
    final user = sb.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    final sb = client;
    if (sb == null) {
      return Stream.value(_mockUser);
    }
    return sb.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? UserModel.fromSupabaseUser(user) : null;
    });
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final sb = client;
    if (sb == null) {
      _mockUser = UserModel(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        fullName: cleanEmail.split('@').first,
        createdAt: DateTime.now(),
      );
      return _mockUser!;
    }

    final response = await sb.auth.signInWithPassword(
      email: cleanEmail,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in failed: No user returned');
    }
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    String? companyName,
  }) async {
    final cleanEmail = email.trim();
    final cleanFullName = fullName?.trim();
    final cleanCompanyName = companyName?.trim();
    final sb = client;

    if (sb == null) {
      _mockUser = UserModel(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        fullName: cleanFullName,
        companyName: cleanCompanyName,
        createdAt: DateTime.now(),
      );
      return _mockUser!;
    }

    final response = await sb.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {
        if (cleanFullName != null && cleanFullName.isNotEmpty)
          'full_name': cleanFullName,
        if (cleanCompanyName != null && cleanCompanyName.isNotEmpty)
          'company_name': cleanCompanyName,
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign up failed: No user returned');
    }

    if (cleanCompanyName != null && cleanCompanyName.isNotEmpty) {
      try {
        await sb.from('companies').upsert({
          'user_id': user.id,
          'name': cleanCompanyName,
          'email': cleanEmail,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Non-blocking during registration
      }
    }

    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<void> signOut() async {
    final sb = client;
    if (sb == null) {
      _mockUser = null;
      return;
    }
    await sb.auth.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    final sb = client;
    if (sb != null) {
      await sb.auth.resetPasswordForEmail(email.trim());
    }
  }
}
