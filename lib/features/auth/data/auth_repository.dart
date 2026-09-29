import '../models/user_model.dart';

abstract class AuthRepository {
  UserModel? getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
    String? companyName,
  });
  Future<void> signOut();
  Future<void> resetPassword({required String email});
}
