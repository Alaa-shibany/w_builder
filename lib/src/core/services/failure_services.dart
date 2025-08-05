import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
// import 'package:flutter/src/widgets/framework.dart';
import 'failure_service/auth_failure.dart';
import 'failure_service/failure.dart';
import 'failure_service/internet_failure.dart';
import 'failure_service/generice_failure.dart';

class FailureFactory extends Failure {
  FailureFactory(super.message);
  static Failure fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return InternetFailure(
          "The connection timed out. Please check your internet connection and try again.",
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return InternetFailure(
          "Oops! It looks like you are offline. Please check your connection and try again.",
        );
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return AuthFailure('Unauthorized access. Please log in again.');
        }
        return GenericFailureFactory(
          'Something went wrong on the server. Please try again later. Status code: ${e.response?.data['message']}',
        );
      default:
        return GenericFailureFactory(
          'An unexpected error occurred. Please try again.',
        );
    }
  }

  @override
  Future<void> handle(BuildContext context, {void Function()? onRetry}) {
    GenericFailureFactory('An unexpected error occurred. Please try again.');
    throw UnimplementedError();
  }
}
