import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/employee.dart';
import '../models/employee_model.dart';

class EmployeeRemoteDataSource {
  final Dio dio;
  EmployeeRemoteDataSource(this.dio);

  Future<List<EmployeeModel>> getAll() async {
    try {
      final response = await dio.get(ApiConstants.employee);
      final data = response.data;
      if (data is! List) throw const AppFailure('Unexpected employee response.');
      return data.map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) { throw _mapError(e); }
  }

  Future<EmployeeModel> getById(String id) async {
    try { final r = await dio.get('${ApiConstants.employee}/$id'); return EmployeeModel.fromJson(Map<String, dynamic>.from(r.data)); }
    catch (e) { throw _mapError(e); }
  }
  Future<EmployeeModel> create(Employee employee) async {
    try { final r = await dio.post(ApiConstants.employee, data: EmployeeModel(name: employee.name, email: employee.email, mobile: employee.mobile, country: employee.country, state: employee.state, district: employee.district).toJson()); return EmployeeModel.fromJson(Map<String, dynamic>.from(r.data)); }
    catch (e) { throw _mapError(e); }
  }
  Future<EmployeeModel> update(Employee employee) async {
    try { final r = await dio.put('${ApiConstants.employee}/${employee.id}', data: EmployeeModel(name: employee.name, email: employee.email, mobile: employee.mobile, country: employee.country, state: employee.state, district: employee.district).toJson()); return EmployeeModel.fromJson(Map<String, dynamic>.from(r.data)); }
    catch (e) { throw _mapError(e); }
  }
  Future<void> delete(String id) async {
    try { await dio.delete('${ApiConstants.employee}/$id'); } catch (e) { throw _mapError(e); }
  }
  AppFailure _mapError(Object e) {
    if (e is AppFailure) return e;
    if (e is DioException) return AppFailure(e.response?.data?['message']?.toString() ?? (e.type == DioExceptionType.connectionTimeout ? 'Request timed out.' : 'Network request failed.'), cause: e);
    return AppFailure('Unable to complete the request.', cause: e);
  }
}
