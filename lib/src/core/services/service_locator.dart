import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cache_service.dart';
import '../services/end_points.dart';
import '../services/interceptors/auth_interceptor.dart';

import 'api_services.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // It will be created only ONCE

  sl.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  sl.registerLazySingleton<CacheService>(
    () => CacheService(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(cacheService: sl()),
  );

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(sl<AuthInterceptor>());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );

    return dio;
  });

  sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl()));
}
