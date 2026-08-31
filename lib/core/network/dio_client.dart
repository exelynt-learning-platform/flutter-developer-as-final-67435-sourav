import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
            sendTimeout: const Duration(seconds: 12),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }
}
