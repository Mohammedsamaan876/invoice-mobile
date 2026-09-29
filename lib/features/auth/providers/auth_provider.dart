import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(client: SupabaseConfig.client);
});

final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

class CurrentUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    final repo = ref.watch(authRepositoryProvider);
    ref.listen(authStateChangesProvider, (_, next) {
      if (next.hasValue) {
        state = next.value;
      }
    });
    return repo.getCurrentUser();
  }

  void setUser(UserModel? user) {
    state = user;
  }
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, UserModel?>(CurrentUserNotifier.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

class AuthController extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() => const AsyncValue.data(null);

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn(email: email, password: password);
      ref.read(currentUserProvider.notifier).setUser(user);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? fullName,
    String? companyName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        companyName: companyName,
      );
      ref.read(currentUserProvider.notifier).setUser(user);
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      ref.read(currentUserProvider.notifier).setUser(null);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<UserModel?>>(
  AuthController.new,
);
