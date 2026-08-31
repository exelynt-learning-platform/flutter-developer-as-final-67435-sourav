import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/employee_usecases.dart';

sealed class EmployeeState {}
class EmployeeInitial extends EmployeeState {}
class EmployeeLoading extends EmployeeState {}
class EmployeeLoaded extends EmployeeState { final List<Employee> employees; final String searchId; final String filter; final String filterText; EmployeeLoaded(this.employees, {this.searchId = '', this.filter = 'All', this.filterText = ''}); List<Employee> get visible { var list = employees; if (searchId.trim().isNotEmpty) list = list.where((e) => e.id.toLowerCase().contains(searchId.trim().toLowerCase())).toList(); if (filter != 'All' && filterText.trim().isNotEmpty) { final q = filterText.toLowerCase(); list = list.where((e) { switch(filter) { case 'Name': return e.name.toLowerCase().contains(q); case 'Email': return e.email.toLowerCase().contains(q); case 'Mobile': return e.mobile.toLowerCase().contains(q); case 'Country': return e.country.toLowerCase().contains(q); default: return true; } }).toList(); } return list; } }
class EmployeeEmpty extends EmployeeState {}
class EmployeeError extends EmployeeState { final String message; EmployeeError(this.message); }

class EmployeeCubit extends Cubit<EmployeeState> {
  final GetEmployees getEmployees; final GetEmployeeById getById; final CreateEmployee createEmployee; final UpdateEmployee updateEmployee; final DeleteEmployee deleteEmployee;
  EmployeeCubit({required this.getEmployees, required this.getById, required this.createEmployee, required this.updateEmployee, required this.deleteEmployee}) : super(EmployeeInitial());
  Future<void> load() async { emit(EmployeeLoading()); try { final list = await getEmployees(); emit(list.isEmpty ? EmployeeEmpty() : EmployeeLoaded(list)); } catch(e) { emit(EmployeeError(e.toString().replaceFirst('AppFailure: ', ''))); } }
  void searchId(String value) { final s = state; if (s is EmployeeLoaded) emit(EmployeeLoaded(s.employees, searchId: value, filter: s.filter, filterText: s.filterText)); }
  void filter(String type, String text) { final s = state; if (s is EmployeeLoaded) emit(EmployeeLoaded(s.employees, searchId: s.searchId, filter: type, filterText: text)); }
  Future<Employee?> save(Employee e) async { try { final result = e.id.isEmpty ? await createEmployee(e) : await updateEmployee(e); await load(); return result; } catch(e) { emit(EmployeeError(e.toString().replaceFirst('AppFailure: ', ''))); return null; } }
  Future<bool> remove(String id) async { try { await deleteEmployee(id); await load(); return true; } catch(e) { emit(EmployeeError(e.toString().replaceFirst('AppFailure: ', ''))); return false; } }
  Future<Employee?> fetchById(String id) async { try { return await getById(id); } catch (_) { return null; } }
}
