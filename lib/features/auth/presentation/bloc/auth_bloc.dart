import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState { final AppUser user; const Authenticated(this.user); @override List<Object?> get props => [user]; }
class Unauthenticated extends AuthState {}
class AuthFailure extends AuthState { final String message; const AuthFailure(this.message); @override List<Object?> get props => [message]; }
class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleUseCase;
  final ResetPasswordUseCase resetUseCase;
  final SignOutUseCase signOutUseCase;

  StreamSubscription<AppUser?>? _subscription;

  AuthCubit({
    required this.repository,
    required this.signInUseCase,
    required this.registerUseCase,
    required this.googleUseCase,
    required this.resetUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    _subscription = repository.authStateChanges().listen(
          (user) {
        if (user == null) {
          emit(Unauthenticated());
        } else {
          emit(Authenticated(user));
        }
      },
      onError: (error) {
        emit(
          AuthFailure(
            'Unable to check authentication status.',
          ),
        );
      },
    );
  }

  // ===============================================================
  // SIGN IN
  // ===============================================================

  Future<void> signIn(
      String email,
      String password,
      ) async {
    emit(AuthLoading());

    final result = await signInUseCase(
      email,
      password,
    );

    if (result.isSuccess && result.user != null) {
      emit(
        Authenticated(result.user!),
      );
    } else {
      emit(
        AuthFailure(
          result.failure?.message ??
              'Unable to sign in.',
        ),
      );
    }
  }

  // ===============================================================
  // REGISTER
  // ===============================================================

  Future<void> register(
      String name,
      String email,
      String password,
      ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      name,
      email,
      password,
    );

    if (result.isSuccess && result.user != null) {
      emit(
        Authenticated(result.user!),
      );
    } else {
      emit(
        AuthFailure(
          result.failure?.message ??
              'Unable to create account.',
        ),
      );
    }
  }

  // ===============================================================
  // GOOGLE SIGN IN
  // ===============================================================

  Future<void> google() async {
    emit(AuthLoading());

    final result = await googleUseCase();

    if (result.isSuccess && result.user != null) {
      emit(
        Authenticated(result.user!),
      );
    } else {
      emit(
        AuthFailure(
          result.failure?.message ??
              'Unable to sign in with Google.',
        ),
      );
    }
  }

  // ===============================================================
  // RESET PASSWORD
  // ===============================================================

  Future<String?> resetPassword(
      String email,
      ) async {
    emit(AuthLoading());

    final failure = await resetUseCase(
      email.trim(),
    );

    if (failure != null) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );

      return failure.message;
    }

    // Password reset succeeded.
    // Do not change the authentication state.
    emit(
      const PasswordResetSuccess(),
    );

    return null;
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================

  Future<void> logout() async {
    emit(AuthLoading());

    final failure = await signOutUseCase();

    if (failure != null) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );

      return;
    }

    // Firebase authStateChanges() will normally
    // emit null and transition the application to
    // Unauthenticated.
  }

  // ===============================================================
  // CLOSE
  // ===============================================================

  @override
  Future<void> close() async {
    await _subscription?.cancel();

    return super.close();
  }
}
