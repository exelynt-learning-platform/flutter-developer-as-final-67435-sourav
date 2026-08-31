import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.country,
    required super.state,
    required super.district,
  });

  factory EmployeeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return EmployeeModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      mobile: '${json['mobile'] ?? json['phone'] ?? ''}',
      country: '${json['country'] ?? ''}',
      state: '${json['state'] ?? ''}',
      district: '${json['district'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'country': country,
      'state': state,
      'district': district,
    };
  }
}