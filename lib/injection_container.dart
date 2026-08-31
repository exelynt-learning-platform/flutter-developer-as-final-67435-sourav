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
  // ===============================================================
  // Hive initialization
  // ===============================================================

  await Hive.initFlutter();

  final box = await Hive.openBox<String>(
    'employee_cache',
  );

  // ===============================================================
  // Shared Preferences
  // ===============================================================

  final prefs = await SharedPreferences.getInstance();

  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerLazySingleton<SharedPreferences>(
          () => prefs,
    );
  }

  // ===============================================================
  // Network
  // ===============================================================

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient().dio,
    );
  }

  // ===============================================================
  // Firebase Authentication
  // ===============================================================

  final firebaseReady = Firebase.apps.isNotEmpty;

  if (!sl.isRegistered<AuthRepository>()) {
    if (firebaseReady) {
      if (!sl.isRegistered<FirebaseAuth>()) {
        sl.registerLazySingleton<FirebaseAuth>(
              () => FirebaseAuth.instance,
        );
      }

      if (!sl.isRegistered<GoogleSignIn>()) {
        sl.registerLazySingleton<GoogleSignIn>(
              () => GoogleSignIn(
            scopes: ['email'],
          ),
        );
      }

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
  }

  // ===============================================================
  // Authentication Use Cases
  // ===============================================================

  if (!sl.isRegistered<SignInUseCase>()) {
    sl.registerLazySingleton(
          () => SignInUseCase(sl()),
    );
  }

  if (!sl.isRegistered<RegisterUseCase>()) {
    sl.registerLazySingleton(
          () => RegisterUseCase(sl()),
    );
  }

  if (!sl.isRegistered<GoogleSignInUseCase>()) {
    sl.registerLazySingleton(
          () => GoogleSignInUseCase(sl()),
    );
  }

  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerLazySingleton(
          () => ResetPasswordUseCase(sl()),
    );
  }

  if (!sl.isRegistered<SignOutUseCase>()) {
    sl.registerLazySingleton(
          () => SignOutUseCase(sl()),
    );
  }

  // ===============================================================
  // Authentication Cubit
  // ===============================================================

  if (!sl.isRegistered<AuthCubit>()) {
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
  }

  // ===============================================================
  // Employee Remote Data Source
  // ===============================================================

  if (!sl.isRegistered<EmployeeRemoteDataSource>()) {
    sl.registerLazySingleton<EmployeeRemoteDataSource>(
          () => EmployeeRemoteDataSource(sl()),
    );
  }

  // ===============================================================
  // Country Remote Data Source
  // ===============================================================

  if (!sl.isRegistered<CountryRemoteDataSource>()) {
    sl.registerLazySingleton<CountryRemoteDataSource>(
          () => CountryRemoteDataSource(sl()),
    );
  }

  // ===============================================================
  // Country Repository
  // ===============================================================

  if (!sl.isRegistered<CountryRepository>()) {
    sl.registerLazySingleton<CountryRepository>(
          () => CountryRepositoryImpl(sl()),
    );
  }

  // ===============================================================
  // Country Cubit
  // ===============================================================

  if (!sl.isRegistered<CountryCubit>()) {
    sl.registerFactory(
          () => CountryCubit(sl()),
    );
  }

  // ===============================================================
  // Employee Local Data Source
  // ===============================================================

  if (!sl.isRegistered<EmployeeLocalDataSource>()) {
    sl.registerLazySingleton<EmployeeLocalDataSource>(
          () => EmployeeLocalDataSource(box),
    );
  }

  // ===============================================================
  // Employee Repository
  // ===============================================================

  if (!sl.isRegistered<EmployeeRepository>()) {
    sl.registerLazySingleton<EmployeeRepository>(
          () => EmployeeRepositoryImpl(
        remote: sl(),
        local: sl(),
      ),
    );
  }

  // ===============================================================
  // Employee Use Cases
  // ===============================================================

  if (!sl.isRegistered<GetEmployees>()) {
    sl.registerLazySingleton(
          () => GetEmployees(sl()),
    );
  }

  if (!sl.isRegistered<GetEmployeeById>()) {
    sl.registerLazySingleton(
          () => GetEmployeeById(sl()),
    );
  }

  if (!sl.isRegistered<CreateEmployee>()) {
    sl.registerLazySingleton(
          () => CreateEmployee(sl()),
    );
  }

  if (!sl.isRegistered<UpdateEmployee>()) {
    sl.registerLazySingleton(
          () => UpdateEmployee(sl()),
    );
  }

  if (!sl.isRegistered<DeleteEmployee>()) {
    sl.registerLazySingleton(
          () => DeleteEmployee(sl()),
    );
  }

  // ===============================================================
  // Employee Cubit
  // ===============================================================

  if (!sl.isRegistered<EmployeeCubit>()) {
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
}
