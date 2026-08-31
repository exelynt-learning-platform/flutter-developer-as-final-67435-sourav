import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool register = false;

  @override
  void dispose() { email.dispose(); password.dispose(); name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: formKey,
                    child: BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                        }
                      },
                      builder: (context, state) {
                        final loading = state is AuthLoading;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(Icons.badge_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(register ? 'Create account' : 'Welcome back', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text(register ? 'Register to manage employees' : 'Sign in to continue', textAlign: TextAlign.center),
                            const SizedBox(height: 28),
                            if (register) ...[
                              AppTextField(controller: name, label: 'Full name', validator: (v) => Validators.required(v, 'Name')),
                              const SizedBox(height: 14),
                            ],
                            AppTextField(controller: email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: Validators.email),
                            const SizedBox(height: 14),
                            AppTextField(controller: password, label: 'Password', obscureText: true, validator: Validators.password),
                            if (!register)
                              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: loading ? null : () => _forgot(context), child: const Text('Forgot password?'))),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: loading ? null : () => _submit(context),
                              child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(register ? 'Create account' : 'Sign in'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(onPressed: loading ? null : () => context.read<AuthCubit>().google(), icon: const Icon(Icons.login), label: const Text('Continue with Google')),
                            const SizedBox(height: 12),
                            TextButton(onPressed: loading ? null : () => setState(() => register = !register), child: Text(register ? 'Already have an account? Sign in' : 'New here? Create an account')),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    if (register) await cubit.register(name.text, email.text, password.text);
    else await cubit.signIn(email.text, password.text);
  }

  Future<void> _forgot(BuildContext context) async {
    if (Validators.email(email.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email first.')));
      return;
    }
    final message = await context.read<AuthCubit>().resetPassword(email.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Password reset email sent.')));
  }
}
