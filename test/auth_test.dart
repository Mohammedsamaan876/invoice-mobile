import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/features/auth/data/auth_repository_impl.dart';
import 'package:invoice_app/features/auth/presentation/login_screen.dart';
import 'package:invoice_app/features/auth/providers/auth_provider.dart';

void main() {
  group('Supabase Auth & Riverpod State Tests', () {
    test('1. AuthRepositoryImpl provides sign up, sign in, current user, and sign out', () async {
      final repo = AuthRepositoryImpl();

      // Initial state is null
      expect(repo.getCurrentUser(), isNull);

      // Sign up
      final newUser = await repo.signUp(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        companyName: 'Test Company LLC',
      );

      expect(newUser.email, 'test@example.com');
      expect(newUser.fullName, 'Test User');
      expect(newUser.companyName, 'Test Company LLC');
      expect(repo.getCurrentUser()?.email, 'test@example.com');

      // Sign out
      await repo.signOut();
      expect(repo.getCurrentUser(), isNull);

      // Sign in
      final signedInUser = await repo.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(signedInUser.email, 'test@example.com');
      expect(repo.getCurrentUser()?.email, 'test@example.com');
    });

    test('2. AuthController coordinates state and updates currentUserProvider', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepositoryImpl()),
        ],
      );
      addTearDown(container.dispose);

      // Initial
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);

      final controller = container.read(authControllerProvider.notifier);

      // Sign Up
      final user = await controller.signUp(
        email: 'founder@acme.ae',
        password: 'securePassword123',
        fullName: 'Founder',
        companyName: 'Acme General Trading',
      );

      expect(user?.email, 'founder@acme.ae');
      expect(container.read(currentUserProvider)?.email, 'founder@acme.ae');
      expect(container.read(isAuthenticatedProvider), isTrue);

      // Sign Out
      await controller.signOut();
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);

      // Sign In
      await controller.signIn(
        email: 'founder@acme.ae',
        password: 'securePassword123',
      );
      expect(container.read(currentUserProvider)?.email, 'founder@acme.ae');
      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    testWidgets('3. LoginScreen toggles between Sign In and Sign Up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial: Sign In mode
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.byKey(const Key('auth_fullname_field')), findsNothing);
      expect(find.byKey(const Key('auth_company_field')), findsNothing);

      // Toggle to Sign Up mode
      await tester.tap(find.byKey(const Key('auth_toggle_mode_button')));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
      expect(find.byKey(const Key('auth_fullname_field')), findsOneWidget);
      expect(find.byKey(const Key('auth_company_field')), findsOneWidget);

      // Toggle back to Sign In mode
      await tester.ensureVisible(find.byKey(const Key('auth_toggle_mode_button')));
      await tester.tap(find.byKey(const Key('auth_toggle_mode_button')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('4. LoginScreen validates required email and password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sign In with empty fields
      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('5. LoginScreen successful sign in updates state and closes',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepositoryImpl()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('auth_email_field')),
        'admin@business.com',
      );
      await tester.enterText(
        find.byKey(const Key('auth_password_field')),
        'password123',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(container.read(currentUserProvider)?.email, 'admin@business.com');
      expect(container.read(isAuthenticatedProvider), isTrue);
    });
  });
}
