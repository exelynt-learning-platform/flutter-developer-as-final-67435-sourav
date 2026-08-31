import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);
  Future<AuthResult> call(String email, String password) => repository.signIn(email, password);
}
class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  Future<AuthResult> call(String name, String email, String password) => repository.register(name, email, password);
}
class GoogleSignInUseCase {
  final AuthRepository repository;
  GoogleSignInUseCase(this.repository);
  Future<AuthResult> call() => repository.googleSignIn();
}
class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);
  Future call(String email) => repository.resetPassword(email);
}
class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);
  Future call() => repository.signOut();
}
