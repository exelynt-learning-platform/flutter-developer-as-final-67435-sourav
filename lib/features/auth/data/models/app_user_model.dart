import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({required super.id, required super.name, required super.email, super.photoUrl});

  factory AppUserModel.fromFirebase(User user) => AppUserModel(
        id: user.uid,
        name: user.displayName?.trim().isNotEmpty == true ? user.displayName! : user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
}
