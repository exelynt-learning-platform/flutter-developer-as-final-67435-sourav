import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_app/features/employees/presentation/pages/employee_form_page.dart';
import 'package:employee_management_app/features/employees/domain/entities/employee.dart';
import 'package:employee_management_app/features/employees/domain/repositories/country_repository.dart';
import 'package:employee_management_app/features/employees/presentation/bloc/country_cubit.dart';
void main(){
  testWidgets('employee form shows validation', (tester) async { await tester.pumpWidget(MaterialApp(home:EmployeeFormPage(providedCountryCubit: CountryCubit(_FakeCountryRepository())))); await tester.tap(find.text('Create employee')); await tester.pump(); expect(find.text('Name is required'), findsOneWidget); expect(find.text('Email is required'), findsOneWidget); });
  testWidgets('employee form pre-populates edit data', (tester) async { const e = Employee(id:'1',name:'Alice',email:'alice@example.com',mobile:'9876543210',country:'India',state:'Haryana',district:'Gurgaon'); await tester.pumpWidget(MaterialApp(home:EmployeeFormPage(employee:e, providedCountryCubit: CountryCubit(_FakeCountryRepository())))); expect(find.byType(TextFormField), findsNWidgets(6)); expect(find.text('Edit Employee'), findsOneWidget); });
}

class _FakeCountryRepository implements CountryRepository { @override Future<List<String>> getCountries() async => const []; }
