import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_failure.dart';
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

// ============================================================================
// AUTH CUBIT
// ============================================================================

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
  }) : super( AuthInitial()) {
    _listenToAuthState();
  }

  // ==========================================================================
  // AUTH STATE LISTENER
  // ==========================================================================

  void _listenToAuthState() {
    _subscription = repository.authStateChanges().listen(
          (user) {
        if (isClosed) {
          return;
        }

        if (user == null) {
          emit(Unauthenticated());
        } else {
          emit(
            Authenticated(user),
          );
        }
      },
      onError: (_) {
        if (isClosed) {
          return;
        }

        emit(
          const AuthFailure(
            'Unable to check authentication status.',
          ),
        );
      },
    );
  }

  // ==========================================================================
  // SIGN IN
  // ==========================================================================

  // ===============================================================
// SIGN IN
// ===============================================================

  Future<void> signIn(
      String email,
      String password,
      ) async {
    emit(AuthLoading());

    try {
      final result = await signInUseCase(
        email.trim(),
        password,
      );

      if (!result.isSuccess) {
        emit(
          AuthFailure(
            result.failure?.message ??
                'Unable to sign in.',
          ),
        );
      }

      // Do NOT emit Authenticated here.
      //
      // Successful Firebase sign-in changes the authentication
      // state, and authStateChanges() will emit Authenticated.
    } on AppFailure catch (failure) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          'Unable to sign in. Please try again.',
        ),
      );
    }
  }

  // ==========================================================================
  // REGISTER
  // ==========================================================================

  // ===============================================================
// REGISTER
// ===============================================================

  Future<void> register(
      String name,
      String email,
      String password,
      ) async {
    emit(AuthLoading());

    try {
      final result = await registerUseCase(
        name.trim(),
        email.trim(),
        password,
      );

      if (!result.isSuccess) {
        emit(
          AuthFailure(
            result.failure?.message ??
                'Unable to create account.',
          ),
        );
      }

      // Do NOT emit Authenticated here.
      //
      // authStateChanges() will emit Authenticated
      // after Firebase authentication succeeds.
    } on AppFailure catch (failure) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          'Unable to create account. Please try again.',
        ),
      );
    }
  }

  // ==========================================================================
  // GOOGLE SIGN IN
  // ==========================================================================

  // ===============================================================
// GOOGLE SIGN IN
// ===============================================================

  Future<void> google() async {
    emit(AuthLoading());

    try {
      final result = await googleUseCase();

      if (!result.isSuccess) {
        emit(
          AuthFailure(
            result.failure?.message ??
                'Unable to sign in with Google.',
          ),
        );
      }

      // Do NOT emit Authenticated here.
      //
      // Firebase authStateChanges() will emit Authenticated
      // when the Google authentication succeeds.
    } on AppFailure catch (failure) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          'Unable to sign in with Google. Please try again.',
        ),
      );
    }
  }

  // ==========================================================================
  // RESET PASSWORD
  // ==========================================================================

  Future<String?> resetPassword(
      String email,
      ) async {
    emit( AuthLoading());

    try {
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

      // Password reset does NOT log the user out.
      emit(
        const PasswordResetSuccess(),
      );

      return null;
    } on AppFailure catch (failure) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );

      return failure.message;
    } catch (_) {
      const message =
          'Unable to send password reset email.';

      emit(
        const AuthFailure(message),
      );

      return message;
    }
  }

  // ==========================================================================
  // LOGOUT
  // ==========================================================================

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      final failure = await signOutUseCase();

      if (failure != null) {
        emit(
          AuthFailure(
            failure.message,
          ),
        );

        return;
      }

      // Do not manually emit Unauthenticated here.
      //
      // Firebase authStateChanges() will emit null,
      // which will cause _listenToAuthState() to emit
      // Unauthenticated().
    } on AppFailure catch (failure) {
      emit(
        AuthFailure(
          failure.message,
        ),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          'Unable to sign out. Please try again.',
        ),
      );
    }
  }

  // ==========================================================================
  // CLOSE
  // ==========================================================================

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;

    return super.close();
  }
}


