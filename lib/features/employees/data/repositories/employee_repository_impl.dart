import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_data_source.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remote;
  final Box<String> cache;
  EmployeeRepositoryImpl({required this.remote, required this.cache});

  List<Employee> _readCache() {
    final raw = cache.get('employees');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<void> _writeCache(List<Employee> employees) => cache.put('employees', jsonEncode(employees.map((e) => EmployeeModel(name: e.name, email: e.email, mobile: e.mobile, country: e.country, state: e.state, district: e.district).toJson()..['id'] = e.id).toList()));

  @override Future<List<Employee>> getAll() async { try { final list = await remote.getAll(); await _writeCache(list); return list; } catch (e) { final cached = _readCache(); if (cached.isNotEmpty) return cached; if (e is AppFailure) throw e; rethrow; } }
  @override Future<Employee> getById(String id) => remote.getById(id);
  @override Future<Employee> create(Employee employee) async { final created = await remote.create(employee); final current = _readCache()..add(created); await _writeCache(current); return created; }
  @override Future<Employee> update(Employee employee) async { final updated = await remote.update(employee); final current = _readCache(); final i = current.indexWhere((e) => e.id == updated.id); if (i >= 0) current[i] = updated; else current.add(updated); await _writeCache(current); return updated; }
  @override Future<void> delete(String id) async { await remote.delete(id); final current = _readCache()..removeWhere((e) => e.id == id); await _writeCache(current); }
}
