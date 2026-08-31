import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/employee_usecases.dart';

import 'package:equatable/equatable.dart';

import '../../domain/entities/employee.dart';

enum EmployeeStatus {
  initial,
  loading,
  success,
  error,
}

class EmployeeState extends Equatable {
  final EmployeeStatus status;
  final List<Employee> employees;
  final String searchId;
  final String filter;
  final String filterText;
  final String? errorMessage;

  const EmployeeState({
    this.status = EmployeeStatus.initial,
    this.employees = const [],
    this.searchId = '',
    this.filter = 'Name',
    this.filterText = '',
    this.errorMessage,
  });

  /// Employees displayed by the UI after search/filter.
  List<Employee> get visible {
    var result = employees;

    // -------------------------------------------------------------
    // Search by ID
    // -------------------------------------------------------------

    final id = searchId.trim();

    if (id.isNotEmpty) {
      result = result
          .where(
            (employee) => employee.id == id,
      )
          .toList();
    }

    // -------------------------------------------------------------
    // Filter
    // -------------------------------------------------------------

    final text = filterText.trim().toLowerCase();

    if (text.isNotEmpty) {
      result = result.where((employee) {
        switch (filter) {
          case 'Name':
            return employee.name.toLowerCase().contains(text);

          case 'Email':
            return employee.email.toLowerCase().contains(text);

          case 'Mobile':
            return employee.mobile.toLowerCase().contains(text);

          case 'Country':
            return employee.country.toLowerCase().contains(text);

          default:
            return true;
        }
      }).toList();
    }

    return result;
  }

  EmployeeState copyWith({
    EmployeeStatus? status,
    List<Employee>? employees,
    String? searchId,
    String? filter,
    String? filterText,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmployeeState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      searchId: searchId ?? this.searchId,
      filter: filter ?? this.filter,
      filterText: filterText ?? this.filterText,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    employees,
    searchId,
    filter,
    filterText,
    errorMessage,
  ];
}



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
  }) : super(const EmployeeState());

  // ===============================================================
  // LOAD EMPLOYEES
  // ===============================================================

  Future<void> load() async {
    emit(
      state.copyWith(
        status: EmployeeStatus.loading,
        clearError: true,
      ),
    );

    try {
      final employees = await getEmployees();

      emit(
        state.copyWith(
          status: EmployeeStatus.success,
          employees: employees,
          clearError: true,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: failure.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Unable to load employees.',
        ),
      );
    }
  }

  // ===============================================================
  // SEARCH BY ID
  // ===============================================================

  void searchId(String value) {
    emit(
      state.copyWith(
        searchId: value,
      ),
    );
  }

  // ===============================================================
  // FILTER
  // ===============================================================

  void filter(
      String type,
      String text,
      ) {
    emit(
      state.copyWith(
        filter: type,
        filterText: text,
      ),
    );
  }

  // ===============================================================
  // CREATE / UPDATE
  // ===============================================================

  Future<Employee?> save(Employee employee) async {
    try {
      final Employee result;

      if (employee.id.trim().isEmpty) {
        result = await createEmployee(employee);
      } else {
        result = await updateEmployee(employee);
      }

      // Reload from repository so the UI always reflects
      // the latest server/cache state.
      await load();

      return result;
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: failure.message,
        ),
      );

      return null;
    } catch (_) {
      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Unable to save employee.',
        ),
      );

      return null;
    }
  }

  // ===============================================================
  // DELETE
  // ===============================================================

  Future<bool> remove(String id) async {
    try {
      await deleteEmployee(id);

      await load();

      return true;
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: failure.message,
        ),
      );

      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Unable to delete employee.',
        ),
      );

      return false;
    }
  }

  // ===============================================================
  // GET EMPLOYEE BY ID
  // ===============================================================

  Future<Employee?> fetchById(String id) async {
    try {
      return await getById(id);
    } on AppFailure {
      return null;
    } catch (_) {
      return null;
    }
  }
}
