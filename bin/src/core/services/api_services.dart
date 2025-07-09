import 'dio_settings.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService._(this._dio);

  static final ApiService _instance = ApiService._(DioClient.instance);

  factory ApiService() {
    return _instance;
  }

  // ----------GET Request----------
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Object? data,
  }) async {
    printUrl(endpoint);

    final response = await _dio.get(
      endpoint,
      queryParameters: queryParams,
      data: data,
    );
    printResponse(response);
    return response;
  }

  // ----------POST Request----------
  Future<Response> post(String endpoint, {required Object? data}) async {
    printUrl(endpoint);
    final response = await _dio.post(endpoint, data: data);
    printResponse(response);
    return response;
  }

  // ----------Delete Request----------
  Future<Response> delete(String endpoint, {required Object? data}) async {
    printUrl(endpoint);
    final response = await _dio.delete(endpoint, data: data);
    printResponse(response);
    return response;
  }

  // ----------PUT Request----------
  Future<Response> put(String endpoint, {required Object? data}) async {
    printUrl(endpoint);
    final response = await _dio.put(endpoint, data: data);
    printResponse(response);
    return response;
  }

  void printUrl(String endpoint) {
    print("${_dio.options.baseUrl}$endpoint");
  }

  void printResponse(Response<dynamic> response) {
    print("response =>${response.statusCode}\n${response.data}");
  }
}
