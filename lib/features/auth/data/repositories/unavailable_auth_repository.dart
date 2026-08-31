import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();
  @override Stream<AppUser?> authStateChanges() => Stream.value(null);
  AppFailure get _failure => const AppFailure('Firebase is not configured. Run flutterfire configure first.');
  @override Future<AuthResult> signIn(String email, String password) => Future.value(AuthResult(failure: _failure));
  @override Future<AuthResult> register(String name, String email, String password) => Future.value(AuthResult(failure: _failure));
  @override Future<AuthResult> googleSignIn() => Future.value(AuthResult(failure: _failure));
  @override Future<AppFailure?> resetPassword(String email) => Future.value(_failure);
  @override Future<AppFailure?> signOut() => Future.value(null);
}
