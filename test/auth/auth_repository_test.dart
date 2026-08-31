import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_app/core/errors/app_failure.dart';
import 'package:employee_management_app/features/auth/domain/entities/app_user.dart';
import 'package:employee_management_app/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override Stream<AppUser?> authStateChanges()=>Stream.value(null);
  @override Future<AuthResult> signIn(String email,String password)=>Future.value(const AuthResult(failure:AppFailure('Invalid email or password.')));
  @override Future<AuthResult> register(String name,String email,String password)=>Future.value(const AuthResult(user:AppUser(id:'1',name:'Test',email:'test@example.com')));
  @override Future<AuthResult> googleSignIn()=>Future.value(const AuthResult(user:AppUser(id:'2',name:'Google User',email:'google@example.com')));
  @override Future<AppFailure?> resetPassword(String email)=>Future.value(null);
  @override Future<AppFailure?> signOut()=>Future.value(null);
}
void main(){
  final repo=FakeAuthRepository();
  test('registration succeeds',() async { final r=await repo.register('Test','test@example.com','secret1'); expect(r.isSuccess,true); expect(r.user!.name,'Test'); });
  test('login failure is represented',() async { final r=await repo.signIn('bad@example.com','bad'); expect(r.isSuccess,false); expect(r.failure, isNotNull); });
  test('google sign-in returns user',() async { final r=await repo.googleSignIn(); expect(r.user!.email,'google@example.com'); });
}
