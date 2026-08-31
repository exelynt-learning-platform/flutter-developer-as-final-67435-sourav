import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/data/repositories/unavailable_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/employees/data/datasources/employee_remote_data_source.dart';
import 'features/employees/data/datasources/country_remote_data_source.dart';
import 'features/employees/data/repositories/country_repository_impl.dart';
import 'features/employees/domain/repositories/country_repository.dart';
import 'features/employees/presentation/bloc/country_cubit.dart';
import 'features/employees/data/repositories/employee_repository_impl.dart';
import 'features/employees/domain/repositories/employee_repository.dart';
import 'features/employees/domain/usecases/employee_usecases.dart';
import 'features/employees/presentation/bloc/employee_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final box = await Hive.openBox<String>('employee_cache');
  sl.registerLazySingleton<Dio>(() => DioClient().dio);
  final firebaseReady = Firebase.apps.isNotEmpty;
  if (firebaseReady) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(scopes: ['email']));
    sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository(auth: sl(), googleSignIn: sl()));
  } else {
    sl.registerLazySingleton<AuthRepository>(() => const UnavailableAuthRepository());
  }
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerFactory(() => AuthCubit(repository: sl(), signInUseCase: sl(), registerUseCase: sl(), googleUseCase: sl(), resetUseCase: sl(), signOutUseCase: sl()));
  sl.registerLazySingleton<EmployeeRemoteDataSource>(() => EmployeeRemoteDataSource(sl()));
  sl.registerLazySingleton<CountryRemoteDataSource>(() => CountryRemoteDataSource(sl()));
  sl.registerLazySingleton<CountryRepository>(() => CountryRepositoryImpl(sl()));
  sl.registerFactory(() => CountryCubit(sl()));
  sl.registerLazySingleton<EmployeeRepository>(() => EmployeeRepositoryImpl(remote: sl(), cache: box));
  sl.registerLazySingleton(() => GetEmployees(sl()));
  sl.registerLazySingleton(() => GetEmployeeById(sl()));
  sl.registerLazySingleton(() => CreateEmployee(sl()));
  sl.registerLazySingleton(() => UpdateEmployee(sl()));
  sl.registerLazySingleton(() => DeleteEmployee(sl()));
  sl.registerFactory(() => EmployeeCubit(getEmployees: sl(), getById: sl(), createEmployee: sl(), updateEmployee: sl(), deleteEmployee: sl()));
}
