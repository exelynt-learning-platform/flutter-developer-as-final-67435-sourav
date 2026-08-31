import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/employees/presentation/pages/employee_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  SharedPreferences.getInstance();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch (_) {}
  await configureDependencies();
  runApp(const EmployeeManagementApp());
}

class EmployeeManagementApp extends StatefulWidget {
  const EmployeeManagementApp({super.key});
  @override State<EmployeeManagementApp> createState() => _EmployeeManagementAppState();
}
class _EmployeeManagementAppState extends State<EmployeeManagementApp> {
  ThemeMode mode = ThemeMode.system;
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Employee Management', debugShowCheckedModeBanner: false, theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: mode,
    home: BlocProvider(create: (_) => sl<AuthCubit>(), child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (state is Authenticated) return EmployeeDashboardPage(user: state.user, onToggleTheme: () => setState(() => mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark));
      if (state is AuthLoading || state is AuthInitial) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return const LoginPage();
    })),
  );
}
