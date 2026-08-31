import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_app/features/employees/domain/entities/employee.dart';
import 'package:employee_management_app/features/employees/domain/repositories/employee_repository.dart';
import 'package:employee_management_app/features/employees/domain/usecases/employee_usecases.dart';
import 'package:employee_management_app/features/employees/presentation/bloc/employee_cubit.dart';

class FakeRepository implements EmployeeRepository {
  final items = <Employee>[const Employee(id:'1',name:'Alice',email:'alice@example.com',mobile:'9876543210',country:'India',state:'Haryana',district:'Gurgaon'),const Employee(id:'2',name:'Bob',email:'bob@example.com',mobile:'9999999999',country:'USA',state:'Texas',district:'Austin')];
  @override Future<List<Employee>> getAll()=>Future.value(items);
  @override Future<Employee> getById(String id)=>Future.value(items.firstWhere((e)=>e.id==id));
  @override Future<Employee> create(Employee e)=>Future.value(e.copyWith(id:'3'));
  @override Future<Employee> update(Employee e)=>Future.value(e);
  @override Future<void> delete(String id)=>Future.value();
}
void main(){
  late EmployeeCubit cubit;
  setUp(() { final r=FakeRepository(); cubit=EmployeeCubit(getEmployees:GetEmployees(r),getById:GetEmployeeById(r),createEmployee:CreateEmployee(r),updateEmployee:UpdateEmployee(r),deleteEmployee:DeleteEmployee(r)); });
  tearDown(()=>cubit.close());
  test('loads and filters employees', () async {
    await cubit.load();

    expect(
      cubit.state.status,
      EmployeeStatus.success,
    );

    expect(
      cubit.state.employees.length,
      2,
    );

    cubit.filter('Name', 'alice');

    expect(
      cubit.state.visible.length,
      1,
    );

    expect(
      cubit.state.visible.first.name,
      'Alice',
    );
  });

  test('searches by employee id', () async {
    await cubit.load();

    expect(
      cubit.state.status,
      EmployeeStatus.success,
    );

    cubit.searchId('2');

    expect(
      cubit.state.visible.length,
      1,
    );

    expect(
      cubit.state.visible.first.name,
      'Bob',
    );
  });
}
