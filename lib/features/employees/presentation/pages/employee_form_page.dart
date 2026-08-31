import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/employee.dart';
import '../bloc/country_cubit.dart';

class EmployeeFormPage extends StatefulWidget {
  final Employee? employee;
  final CountryCubit? providedCountryCubit;
  const EmployeeFormPage({super.key, this.employee, this.providedCountryCubit});
  @override State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.employee?.name ?? '');
  late final email = TextEditingController(text: widget.employee?.email ?? '');
  late final mobile = TextEditingController(text: widget.employee?.mobile ?? '');
  late final country = TextEditingController(text: widget.employee?.country ?? '');
  late final state = TextEditingController(text: widget.employee?.state ?? '');
  late final district = TextEditingController(text: widget.employee?.district ?? '');
  late final CountryCubit countryCubit;
  bool ownsCountryCubit = false;

  @override void initState() { super.initState(); countryCubit = widget.providedCountryCubit ?? sl<CountryCubit>();
    ownsCountryCubit = widget.providedCountryCubit == null;
    countryCubit.load(); }
  @override void dispose() { if (ownsCountryCubit) countryCubit.close(); for (final c in [name,email,mobile,country,state,district]) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: countryCubit,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      AppTextField(controller: name, label: 'Name', validator: (v) => Validators.required(v, 'Name')),
                      const SizedBox(height: 14),
                      AppTextField(controller: email, label: 'Email', validator: Validators.email),
                      const SizedBox(height: 14),
                      AppTextField(controller: mobile, label: 'Mobile', keyboardType: TextInputType.phone, validator: Validators.mobile),
                      const SizedBox(height: 14),
                      BlocBuilder<CountryCubit, CountryState>(builder: (context, countryState) {
                        if (countryState.countries.isEmpty) {
                          return AppTextField(controller: country, label: 'Country', validator: (v) => Validators.required(v, 'Country'));
                        }
                        final items = {...countryState.countries, if (country.text.isNotEmpty) country.text}.toList();
                        return DropdownButtonFormField<String>(
                          value: country.text.isNotEmpty ? country.text : null,
                          decoration: const InputDecoration(labelText: 'Country'),
                          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          validator: (v) => Validators.required(v, 'Country'),
                          onChanged: (v) => country.text = v ?? '',
                        );
                      }),
                      const SizedBox(height: 14),
                      LayoutBuilder(builder: (c, b) => b.maxWidth > 600
                          ? Row(children: [Expanded(child: AppTextField(controller: state, label: 'State', validator: (v) => Validators.required(v, 'State'))), const SizedBox(width: 14), Expanded(child: AppTextField(controller: district, label: 'District', validator: (v) => Validators.required(v, 'District')))])
                          : Column(children: [AppTextField(controller: state, label: 'State', validator: (v) => Validators.required(v, 'State')), const SizedBox(height: 14), AppTextField(controller: district, label: 'District', validator: (v) => Validators.required(v, 'District'))])),
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () {
                        if (!key.currentState!.validate()) return;
                        Navigator.pop(context, Employee(id: widget.employee?.id ?? '', name: name.text.trim(), email: email.text.trim(), mobile: mobile.text.trim(), country: country.text.trim(), state: state.text.trim(), district: district.text.trim()));
                      }, icon: const Icon(Icons.save_outlined), label: Text(widget.employee == null ? 'Create employee' : 'Save changes'))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
