import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/employee.dart';
import '../bloc/country_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_cubit.dart';

class EmployeeFormPage extends StatefulWidget {
  final Employee? employee;
  final CountryCubit? providedCountryCubit;
  final bool readOnly;

  const EmployeeFormPage({
    super.key,
    this.employee,
    this.providedCountryCubit,
    this.readOnly = false,
  });

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  late final EmployeeCubit _employeeCubit;
  late final CountryCubit _countryCubit;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _countryController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;

  bool _saving = false;

  bool get _isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();

    _employeeCubit = sl<EmployeeCubit>();

    _countryCubit =
        widget.providedCountryCubit ?? sl<CountryCubit>();

    final employee = widget.employee;

    _nameController = TextEditingController(
      text: employee?.name ?? '',
    );

    _emailController = TextEditingController(
      text: employee?.email ?? '',
    );

    _mobileController = TextEditingController(
      text: employee?.mobile ?? '',
    );

    _countryController = TextEditingController(
      text: employee?.country ?? '',
    );

    _stateController = TextEditingController(
      text: employee?.state ?? '',
    );

    _districtController = TextEditingController(
      text: employee?.district ?? '',
    );

    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      await _countryCubit.load();
    } catch (_) {
      // Country loading errors are handled by CountryCubit.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();

    if (widget.providedCountryCubit == null) {
      _countryCubit.close();
    }

    _employeeCubit.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.readOnly;

    return MultiBlocProvider(
      providers: [
        BlocProvider<EmployeeCubit>.value(
          value: _employeeCubit,
        ),
        BlocProvider<CountryCubit>.value(
          value: _countryCubit,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            readOnly
                ? 'Employee Details'
                : _isEdit
                ? 'Edit Employee'
                : 'Add Employee',
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_outline,
                        enabled: !readOnly,
                        validator: _validateName,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType:
                        TextInputType.emailAddress,
                        enabled: !readOnly,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _mobileController,
                        label: 'Mobile',
                        icon: Icons.phone_outlined,
                        keyboardType:
                        TextInputType.phone,
                        enabled: !readOnly,
                        validator: _validateMobile,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        icon: Icons.public,
                        enabled: !readOnly,
                        validator: _validateRequired,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _stateController,
                        label: 'State',
                        icon: Icons.location_city_outlined,
                        enabled: !readOnly,
                        validator: _validateRequired,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _districtController,
                        label: 'District',
                        icon: Icons.location_on_outlined,
                        enabled: !readOnly,
                        validator: _validateRequired,
                      ),

                      if (!readOnly) ...[
                        const SizedBox(height: 28),

                        BlocBuilder<EmployeeCubit,
                            EmployeeState>(
                          bloc: _employeeCubit,
                          builder: (context, state) {
                            return SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                onPressed:
                                _saving ? null : _saveEmployee,
                                icon: _saving
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Icon(Icons.save),
                                label: Text(
                                  _saving
                                      ? 'Saving...'
                                      : _isEdit
                                      ? 'Update Employee'
                                      : 'Save Employee',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Mobile number is required';
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      return 'Enter a valid 10 digit mobile number';
    }

    return null;
  }

  Future<void> _saveEmployee() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final employee = Employee(
      id: widget.employee?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      country: _countryController.text.trim(),
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
    );

    try {
      final saved = await _employeeCubit.save(employee);

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      if (saved != null) {
        Navigator.pop(context, saved);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save employee. Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save employee: $e',
          ),
        ),
      );
    }
  }
}
