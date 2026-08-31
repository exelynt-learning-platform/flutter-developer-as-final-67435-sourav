import 'package:flutter/material.dart';
import '../../domain/entities/employee.dart';
import '../bloc/country_cubit.dart';

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
  // -------------------------------------------------------------
  // Form
  // -------------------------------------------------------------

  final _formKey = GlobalKey<FormState>();

  // -------------------------------------------------------------
  // Controllers
  // -------------------------------------------------------------

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _countryController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.readOnly
              ? 'Employee Details'
              : widget.employee == null
              ? 'Add Employee'
              : 'Edit Employee',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              enabled: !widget.readOnly,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
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
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _mobileController,
              enabled: !widget.readOnly,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mobile is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _countryController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Country',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Country is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _stateController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'State',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'State is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _districtController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'District',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'District is required';
                }

                return null;
              },
            ),

            if (!widget.readOnly) ...[
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _saveEmployee,
                child: Text(
                  widget.employee == null
                      ? 'Create Employee'
                      : 'Update Employee',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final employee = Employee(
      id: widget.employee?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      country: _countryController.text.trim(),
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
    );

    // Keep your existing save logic here.
  }
}
