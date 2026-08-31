import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    required this.auth,
    required GoogleSignIn googleSignIn,
  }) : _googleSignIn = googleSignIn;

  AppFailure _failure(Object e) => AppFailure(
    _friendly(e),
    cause: e,
  );

  String _friendly(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Invalid email or password.';

        case 'email-already-in-use':
          return 'An account already exists for this email.';

        case 'weak-password':
          return 'Password is too weak.';

        case 'invalid-email':
          return 'Please enter a valid email.';

        case 'network-request-failed':
          return 'Network error. Please try again.';

        default:
          return e.message ?? 'Authentication failed.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return auth.authStateChanges().map(
          (user) => user == null
          ? null
          : AppUserModel.fromFirebase(user),
    );
  }

  @override
  Future<AuthResult> signIn(
      String email,
      String password,
      ) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return const AuthResult(
          failure: AppFailure('Unable to retrieve user information.'),
        );
      }

      return AuthResult(
        user: AppUserModel.fromFirebase(user),
      );
    } catch (e) {
      return AuthResult(
        failure: _failure(e),
      );
    }
  }

  @override
  Future<AuthResult> register(
      String name,
      String email,
      String password,
      ) async {
    try {
      final credential =
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return const AuthResult(
          failure: AppFailure('Unable to create user account.'),
        );
      }

      await user.updateDisplayName(name.trim());
      await user.reload();

      final currentUser = auth.currentUser;

      if (currentUser == null) {
        return const AuthResult(
          failure: AppFailure('Unable to retrieve created user.'),
        );
      }

      return AuthResult(
        user: AppUserModel.fromFirebase(currentUser),
      );
    } catch (e) {
      return AuthResult(
        failure: _failure(e),
      );
    }
  }

  @override
  Future<AuthResult> googleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();

      if (account == null) {
        return const AuthResult(
          failure: AppFailure(
            'Google Sign-In was cancelled.',
          ),
        );
      }

      final authentication = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      final result = await auth.signInWithCredential(
        credential,
      );

      final user = result.user;

      if (user == null) {
        return const AuthResult(
          failure: AppFailure(
            'Unable to retrieve Google user information.',
          ),
        );
      }

      return AuthResult(
        user: AppUserModel.fromFirebase(user),
      );
    } catch (e) {
      return AuthResult(
        failure: _failure(e),
      );
    }
  }

  @override
  Future<AppFailure?> resetPassword(
      String email,
      ) async {
    try {
      await auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return null;
    } catch (e) {
      return _failure(e);
    }
  }

  @override
  Future<AppFailure?> signOut() async {
    try {
      await Future.wait([
        auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      return null;
    } catch (e) {
      return _failure(e);
    }
  }
}
