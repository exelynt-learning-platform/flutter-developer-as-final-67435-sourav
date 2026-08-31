import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/employee_usecases.dart';

sealed class EmployeeState {}
class EmployeeInitial extends EmployeeState {}
class EmployeeLoading extends EmployeeState {}
class EmployeeLoaded extends EmployeeState { final List<Employee> employees; final String searchId; final String filter; final String filterText; EmployeeLoaded(this.employees, {this.searchId = '', this.filter = 'All', this.filterText = ''}); List<Employee> get visible { var list = employees; if (searchId.trim().isNotEmpty) list = list.where((e) => e.id.toLowerCase().contains(searchId.trim().toLowerCase())).toList(); if (filter != 'All' && filterText.trim().isNotEmpty) { final q = filterText.toLowerCase(); list = list.where((e) { switch(filter) { case 'Name': return e.name.toLowerCase().contains(q); case 'Email': return e.email.toLowerCase().contains(q); case 'Mobile': return e.mobile.toLowerCase().contains(q); case 'Country': return e.country.toLowerCase().contains(q); default: return true; } }).toList(); } return list; } }
class EmployeeEmpty extends EmployeeState {}
class EmployeeError extends EmployeeState { final String message; EmployeeError(this.message); }



class EmployeeCubit extends Cubit<EmployeeState> {
  final GetEmployees getEmployees;
  final GetEmployeeById getById;
  final CreateEmployee createEmployee;
  final UpdateEmployee updateEmployee;
  final DeleteEmployee deleteEmployee;

  EmployeeCubit({
    required this.getEmployees,
    required this.getById,
    required this.createEmployee,
    required this.updateEmployee,
    required this.deleteEmployee,
  }) : super(EmployeeInitial());

  // ---------------------------------------------------------------
  // Load employees
  // ---------------------------------------------------------------

  Future<void> load() async {
    emit(EmployeeLoading());

    try {
      final employees = await getEmployees();

      if (employees.isEmpty) {
        emit(EmployeeEmpty());
      } else {
        emit(
          EmployeeLoaded(
            employees,
          ),
        );
      }
    } on AppFailure catch (e) {
      emit(
        EmployeeError(
          e.message,
        ),
      );
    } catch (_) {
      emit(
        EmployeeError(
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  // ---------------------------------------------------------------
  // Search by employee ID
  // ---------------------------------------------------------------

  void searchId(String value) {
    final currentState = state;

    if (currentState is EmployeeLoaded) {
      emit(
        EmployeeLoaded(
          currentState.employees,
          searchId: value,
          filter: currentState.filter,
          filterText: currentState.filterText,
        ),
      );
    }
  }

  // ---------------------------------------------------------------
  // Filter employees
  // ---------------------------------------------------------------

  void filter(
      String type,
      String text,
      ) {
    final currentState = state;

    if (currentState is EmployeeLoaded) {
      emit(
        EmployeeLoaded(
          currentState.employees,
          searchId: currentState.searchId,
          filter: type,
          filterText: text,
        ),
      );
    }
  }

  // ---------------------------------------------------------------
  // Create / Update employee
  // ---------------------------------------------------------------

  Future<Employee?> save(
      Employee employee,
      ) async {
    try {
      final Employee result;

      if (employee.id.isEmpty) {
        result = await createEmployee(employee);
      } else {
        result = await updateEmployee(employee);
      }

      await load();

      return result;
    } on AppFailure catch (e) {
      emit(
        EmployeeError(
          e.message,
        ),
      );

      return null;
    } catch (_) {
      emit(
        EmployeeError(
          'Something went wrong. Please try again.',
        ),
      );

      return null;
    }
  }

  // ---------------------------------------------------------------
  // Delete employee
  // ---------------------------------------------------------------

  Future<bool> remove(
      String id,
      ) async {
    try {
      await deleteEmployee(id);

      await load();

      return true;
    } on AppFailure catch (e) {
      emit(
        EmployeeError(
          e.message,
        ),
      );

      return false;
    } catch (_) {
      emit(
        EmployeeError(
          'Something went wrong. Please try again.',
        ),
      );

      return false;
    }
  }

  // ---------------------------------------------------------------
  // Get employee by ID
  // ---------------------------------------------------------------

  Future<Employee?> fetchById(
      String id,
      ) async {
    try {
      return await getById(id);
    } on AppFailure {
      return null;
    } catch (_) {
      return null;
    }
  }
}
