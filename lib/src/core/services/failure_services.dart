import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerFailure(
            "انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت.");
      case DioExceptionType.connectionError:
        return ServerFailure(
            "عفواً! يبدو أنك غير متصل بالإنترنت.\nيرجى التحقق من اتصالك والمحاولة مرة أخرى.");
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return ServerFailure('Unauthorized access.');
        }
        return ServerFailure(
            'حدث خطأ ما في النظام : => ${e.response!.statusCode}');
      default:
        return ServerFailure('An unexpected error occurred.');
    }
  }
}
