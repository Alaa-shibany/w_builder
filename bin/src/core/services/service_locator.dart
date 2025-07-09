import 'api_services.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // It will be created only ONCE
  sl.registerLazySingleton(() => ApiService());
}
