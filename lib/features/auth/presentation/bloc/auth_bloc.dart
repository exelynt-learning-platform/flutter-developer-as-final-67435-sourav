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

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleUseCase;
  final ResetPasswordUseCase resetUseCase;
  final SignOutUseCase signOutUseCase;
  StreamSubscription<AppUser?>? _subscription;

  AuthCubit({required this.repository, required this.signInUseCase, required this.registerUseCase, required this.googleUseCase, required this.resetUseCase, required this.signOutUseCase}) : super(AuthInitial()) {
    _subscription = repository.authStateChanges().listen((user) {
      if (user == null) { emit(Unauthenticated()); } else { emit(Authenticated(user)); }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading()); final result = await signInUseCase(email, password);
    if (result.isSuccess) emit(Authenticated(result.user!)); else emit(AuthFailure(result.failure!.message));
  }
  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading()); final result = await registerUseCase(name, email, password);
    if (result.isSuccess) emit(Authenticated(result.user!)); else emit(AuthFailure(result.failure!.message));
  }
  Future<void> google() async {
    emit(AuthLoading()); final result = await googleUseCase();
    if (result.isSuccess) emit(Authenticated(result.user!)); else emit(AuthFailure(result.failure!.message));
  }
  Future<String?> resetPassword(String email) async {
    emit(AuthLoading()); final failure = await resetUseCase(email);
    emit(Unauthenticated()); return failure?.message;
  }
  Future<void> logout() async { emit(AuthLoading()); final failure = await signOutUseCase(); if (failure != null) emit(AuthFailure(failure.message)); }
  @override Future<void> close() { _subscription?.cancel(); return super.close(); }
}
