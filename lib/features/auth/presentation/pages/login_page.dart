import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _nameController =
  TextEditingController();

  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: _authListener,
                    builder: (context, state) {
                      final bool isLoading =
                      state is AuthLoading;

                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(
                              context,
                              colorScheme,
                            ),

                            const SizedBox(height: 28),

                            if (_isRegister) ...[
                              AppTextField(
                                controller: _nameController,
                                label: 'Full name',
                                keyboardType:
                                TextInputType.name,
                                textInputAction:
                                TextInputAction.next,
                                enabled: !isLoading,
                                validator: (value) {
                                  return Validators.required(
                                    value,
                                    'Name',
                                  );
                                },
                              ),

                              const SizedBox(height: 14),
                            ],

                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType:
                              TextInputType.emailAddress,
                              textInputAction:
                              TextInputAction.next,
                              enabled: !isLoading,
                              validator: Validators.email,
                            ),

                            const SizedBox(height: 14),

                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                              textInputAction:
                              TextInputAction.done,
                              enabled: !isLoading,
                              validator: Validators.password,
                              onFieldSubmitted: (_) {
                                if (!isLoading) {
                                  _submit(context);
                                }
                              },
                            ),

                            if (!_isRegister)
                              Align(
                                alignment:
                                Alignment.centerRight,
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _forgot(context),
                                  child: const Text(
                                    'Forgot password?',
                                  ),
                                ),
                              ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 48,
                              child: FilledButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _submit(context),
                                child: isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  _isRegister
                                      ? 'Create account'
                                      : 'Sign in',
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => context
                                    .read<AuthCubit>()
                                    .google(),
                                icon: const Icon(
                                  Icons.login,
                                ),
                                label: const Text(
                                  'Continue with Google',
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    _isRegister
                                        ? 'Already have an account?'
                                        : 'New here?',
                                  ),
                                ),
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : _toggleMode,
                                  child: Text(
                                    _isRegister
                                        ? 'Sign in'
                                        : 'Create an account',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader(
      BuildContext context,
      ColorScheme colorScheme,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor:
          colorScheme.primaryContainer,
          child: Icon(
            Icons.badge_outlined,
            size: 34,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          _isRegister
              ? 'Create account'
              : 'Welcome back',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          _isRegister
              ? 'Register to manage employees'
              : 'Sign in to continue',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // AUTH LISTENER
  // ---------------------------------------------------------------------------

  void _authListener(
      BuildContext context,
      AuthState state,
      ) {
    if (!mounted) return;

    if (state is AuthFailure) {
      _showMessage(
        state.message,
        isError: true,
      );
      return;
    }

    if (state is PasswordResetSuccess) {
      _showMessage(
        'Password reset email sent. Please check your inbox.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN / REGISTER
  // ---------------------------------------------------------------------------

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;

    if (formState == null) {
      return;
    }

    if (!formState.validate()) {
      return;
    }

    final cubit = context.read<AuthCubit>();

    if (_isRegister) {
      await cubit.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await cubit.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> _forgot(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    final validationError = Validators.email(email);

    if (validationError != null) {
      _showMessage(
        'Enter a valid email address first.',
        isError: true,
      );
      return;
    }

    await context.read<AuthCubit>().resetPassword(
      email,
    );
  }

  // ---------------------------------------------------------------------------
  // TOGGLE LOGIN / REGISTER
  // ---------------------------------------------------------------------------

  void _toggleMode() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isRegister = !_isRegister;
    });

    _formKey.currentState?.reset();
  }

  // ---------------------------------------------------------------------------
  // SNACKBAR
  // ---------------------------------------------------------------------------

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    final messenger =
    ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context)
              .colorScheme
              .error
              : null,
        ),
      );
  }
}