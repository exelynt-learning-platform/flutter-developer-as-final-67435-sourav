import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/employee_model.dart';

class EmployeeLocalDataSource {
  final Box<String> box;

  static const String _employeesKey = 'employees';

  EmployeeLocalDataSource(this.box);

  List<EmployeeModel> _decode(String raw) {
    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .map(
          (item) => EmployeeModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<void> cacheEmployees(
      List<EmployeeModel> employees,
      ) async {
    await box.put(
      _employeesKey,
      jsonEncode(
        employees.map(
              (employee) => employee.toJson(),
        ).toList(),
      ),
    );
  }

  Future<List<EmployeeModel>> getCachedEmployees() async {
    final raw = box.get(_employeesKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      return _decode(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> addEmployee(
      EmployeeModel employee,
      ) async {
    final employees = await getCachedEmployees();

    employees.add(employee);

    await cacheEmployees(employees);
  }

  Future<void> updateEmployee(
      EmployeeModel employee,
      ) async {
    final employees = await getCachedEmployees();

    final index = employees.indexWhere(
          (item) => item.id == employee.id,
    );

    if (index >= 0) {
      employees[index] = employee;
    } else {
      employees.add(employee);
    }

    await cacheEmployees(employees);
  }

  Future<void> deleteEmployee(
      String id,
      ) async {
    final employees = await getCachedEmployees();

    employees.removeWhere(
          (employee) => employee.id == id,
    );

    await cacheEmployees(employees);
  }

  Future<void> clear() async {
    await box.delete(_employeesKey);
  }
}