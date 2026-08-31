import '../entities/employee.dart';
import '../repositories/employee_repository.dart';
class GetEmployees { final EmployeeRepository r; GetEmployees(this.r); Future<List<Employee>> call() => r.getAll(); }
class GetEmployeeById { final EmployeeRepository r; GetEmployeeById(this.r); Future<Employee> call(String id) => r.getById(id); }
class CreateEmployee { final EmployeeRepository r; CreateEmployee(this.r); Future<Employee> call(Employee e) => r.create(e); }
class UpdateEmployee { final EmployeeRepository r; UpdateEmployee(this.r); Future<Employee> call(Employee e) => r.update(e); }
class DeleteEmployee { final EmployeeRepository r; DeleteEmployee(this.r); Future<void> call(String id) => r.delete(id); }
