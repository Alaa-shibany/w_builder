import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static Dio get instance {
    final dio = Dio();
    dio.options.baseUrl = 'https://nawader.webmyidea.com/api/';
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.headers = {'Accept': 'application/json'};

    // Interceptors for logging or token refresh
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    return dio;
  }
}
