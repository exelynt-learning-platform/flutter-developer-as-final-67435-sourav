import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/data/repositories/unavailable_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/employees/data/datasources/employee_local_data_source.dart';
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
  // ---------------------------------------------------------------
  // Local persistence
  // ---------------------------------------------------------------

  final box = await Hive.openBox<String>(
    'employee_cache',
  );

  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(
        () => prefs,
  );

  sl.registerLazySingleton<EmployeeLocalDataSource>(
        () => EmployeeLocalDataSource(box),
  );

  // ---------------------------------------------------------------
  // Network
  // ---------------------------------------------------------------

  sl.registerLazySingleton<Dio>(
        () => DioClient().dio,
  );

  // ---------------------------------------------------------------
  // Firebase Authentication
  // ---------------------------------------------------------------

  final firebaseReady = Firebase.apps.isNotEmpty;

  if (firebaseReady) {
    sl.registerLazySingleton<FirebaseAuth>(
          () => FirebaseAuth.instance,
    );

    sl.registerLazySingleton<GoogleSignIn>(
          () => GoogleSignIn(
        scopes: ['email'],
      ),
    );

    sl.registerLazySingleton<AuthRepository>(
          () => FirebaseAuthRepository(
        auth: sl<FirebaseAuth>(),
        googleSignIn: sl<GoogleSignIn>(),
      ),
    );
  } else {
    sl.registerLazySingleton<AuthRepository>(
          () => const UnavailableAuthRepository(),
    );
  }

  // ---------------------------------------------------------------
  // Authentication Use Cases
  // ---------------------------------------------------------------

  sl.registerLazySingleton(
        () => SignInUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => RegisterUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => GoogleSignInUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => ResetPasswordUseCase(sl()),
  );

  sl.registerLazySingleton(
        () => SignOutUseCase(sl()),
  );

  // ---------------------------------------------------------------
  // Authentication Cubit
  // ---------------------------------------------------------------

  sl.registerFactory(
        () => AuthCubit(
      repository: sl(),
      signInUseCase: sl(),
      registerUseCase: sl(),
      googleUseCase: sl(),
      resetUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------
  // Employee Remote Data Sources
  // ---------------------------------------------------------------

  sl.registerLazySingleton<EmployeeRemoteDataSource>(
        () => EmployeeRemoteDataSource(sl()),
  );

  // ---------------------------------------------------------------
  // Country Remote Data Source
  // ---------------------------------------------------------------

  sl.registerLazySingleton<CountryRemoteDataSource>(
        () => CountryRemoteDataSource(sl()),
  );

  // ---------------------------------------------------------------
  // Country Repository
  // ---------------------------------------------------------------

  sl.registerLazySingleton<CountryRepository>(
        () => CountryRepositoryImpl(sl()),
  );

  // ---------------------------------------------------------------
  // Country Cubit
  // ---------------------------------------------------------------

  sl.registerFactory(
        () => CountryCubit(sl()),
  );

  // ---------------------------------------------------------------
  // Employee Repository
  // ---------------------------------------------------------------

  sl.registerLazySingleton<EmployeeRepository>(
        () => EmployeeRepositoryImpl(
      remote: sl<EmployeeRemoteDataSource>(),
      local: sl<EmployeeLocalDataSource>(),
    ),
  );

  // ---------------------------------------------------------------
  // Employee Use Cases
  // ---------------------------------------------------------------

  sl.registerLazySingleton(
        () => GetEmployees(sl()),
  );

  sl.registerLazySingleton(
        () => GetEmployeeById(sl()),
  );

  sl.registerLazySingleton(
        () => CreateEmployee(sl()),
  );

  sl.registerLazySingleton(
        () => UpdateEmployee(sl()),
  );

  sl.registerLazySingleton(
        () => DeleteEmployee(sl()),
  );

  // ---------------------------------------------------------------
  // Employee Cubit
  // ---------------------------------------------------------------

  sl.registerFactory(
        () => EmployeeCubit(
      getEmployees: sl(),
      getById: sl(),
      createEmployee: sl(),
      updateEmployee: sl(),
      deleteEmployee: sl(),
    ),
  );
}
