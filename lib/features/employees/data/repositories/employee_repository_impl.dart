import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_local_data_source.dart';
import '../datasources/employee_remote_data_source.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remote;
  final EmployeeLocalDataSource local;

  EmployeeRepositoryImpl({
    required this.remote,
    required this.local,
  });

  EmployeeModel _toModel(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      name: employee.name,
      email: employee.email,
      mobile: employee.mobile,
      country: employee.country,
      state: employee.state,
      district: employee.district,
    );
  }

  @override
  Future<List<Employee>> getAll() async {
    try {
      final employees = await remote.getAll();

      await local.cacheEmployees(
        employees.map(_toModel).toList(),
      );

      return employees;
    } catch (e) {
      final cached = await local.getCachedEmployees();

      if (cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  @override
  Future<Employee> getById(String id) async {
    try {
      return await remote.getById(id);
    } catch (e) {
      final cached = await local.getCachedEmployees();

      try {
        return cached.firstWhere(
              (employee) => employee.id == id,
        );
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<Employee> create(
      Employee employee,
      ) async {
    final created = await remote.create(employee);

    await local.addEmployee(
      _toModel(created),
    );

    return created;
  }

  @override
  Future<Employee> update(
      Employee employee,
      ) async {
    final updated = await remote.update(employee);

    await local.updateEmployee(
      _toModel(updated),
    );

    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);

    await local.deleteEmployee(id);
  }
}