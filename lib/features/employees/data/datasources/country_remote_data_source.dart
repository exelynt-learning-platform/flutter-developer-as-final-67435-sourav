import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
class CountryRemoteDataSource {
  final Dio dio; CountryRemoteDataSource(this.dio);
  Future<List<String>> getCountries() async {
    final response = await dio.get(ApiConstants.country);
    if (response.data is! List) return [];
    return (response.data as List).map((e) {
      if (e is Map) return '${e['name'] ?? e['country'] ?? e['title'] ?? ''}';
      return '$e';
    }).where((e) => e.trim().isNotEmpty).toList();
  }
}
