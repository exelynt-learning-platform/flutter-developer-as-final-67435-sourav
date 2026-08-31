// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:employee_management_app/core/errors/app_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_app/main.dart';
import 'dart:async';
import 'package:employee_management_app/features/auth/domain/entities/app_user.dart';
import 'package:employee_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:employee_management_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:employee_management_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_management_app/features/auth/presentation/pages/login_page.dart';
import 'package:get_it/get_it.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() {
    return Stream.value(null);
  }

  @override
  Future<AuthResult> signIn(
      String email,
      String password,
      ) async {
    return const AuthResult(
      failure: AppFailure(
        'Invalid email or password.',
      ),
    );
  }

  @override
  Future<AuthResult> register(
      String name,
      String email,
      String password,
      ) async {
    return const AuthResult(
      failure: AppFailure(
        'Unable to create account.',
      ),
    );
  }

  @override
  Future<AuthResult> googleSignIn() async {
    return const AuthResult(
      failure: AppFailure(
        'Unable to sign in with Google.',
      ),
    );
  }

  @override
  Future<AppFailure?> resetPassword(
      String email,
      ) async {
    return null;
  }

  @override
  Future<AppFailure?> signOut() async {
    return null;
  }
}

void main() {
  late FakeAuthRepository fakeRepository;
  late AuthCubit authCubit;

  setUp(() async {
    // Reset GetIt so the test does not depend on
    // the production dependency-injection configuration.
    await GetIt.I.reset();

    fakeRepository = FakeAuthRepository();

    authCubit = AuthCubit(
      repository: fakeRepository,
      signInUseCase: SignInUseCase(fakeRepository),
      registerUseCase: RegisterUseCase(fakeRepository),
      googleUseCase: GoogleSignInUseCase(fakeRepository),
      resetUseCase: ResetPasswordUseCase(fakeRepository),
      signOutUseCase: SignOutUseCase(fakeRepository),
    );

    GetIt.I.registerSingleton<AuthCubit>(authCubit);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  // ===============================================================
  // Initial authentication state
  // ===============================================================

  testWidgets(
    'shows LoginPage when user is unauthenticated',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const EmployeeManagementApp(),
      );

      // Allow the authStateChanges() stream to emit null.
      await tester.pump();

      expect(
        find.byType(LoginPage),
        findsOneWidget,
      );
    },
  );

  // ===============================================================
  // Login screen
  // ===============================================================

  testWidgets(
    'login page displays email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const EmployeeManagementApp(),
      );

      await tester.pump();

      expect(
        find.byType(LoginPage),
        findsOneWidget,
      );

      expect(
        find.byType(TextFormField),
        findsWidgets,
      );
    },
  );

  // ===============================================================
  // Login validation
  // ===============================================================

  testWidgets(
    'login form validates empty fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const EmployeeManagementApp(),
      );

      await tester.pump();

      expect(
        find.byType(LoginPage),
        findsOneWidget,
      );

      final loginButton = find.text('Login');

      expect(
        loginButton,
        findsOneWidget,
      );

      await tester.tap(loginButton);

      await tester.pump();

      expect(
        find.textContaining('required'),
        findsWidgets,
      );
    },
  );
}

