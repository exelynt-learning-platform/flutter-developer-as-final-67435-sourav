import '../../../../core/errors/app_failure.dart';
import '../entities/app_user.dart';

class AuthResult {
  final AppUser? user;
  final AppFailure? failure;
  const AuthResult({this.user, this.failure});
  bool get isSuccess => user != null && failure == null;
}

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AuthResult> signIn(String email, String password);
  Future<AuthResult> register(String name, String email, String password);
  Future<AuthResult> googleSignIn();
  Future<AppFailure?> resetPassword(String email);
  Future<AppFailure?> signOut();
}
