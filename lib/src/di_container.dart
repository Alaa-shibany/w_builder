// lib/src/di_container.dart

import 'commands/base_command.dart';
import 'package:get_it/get_it.dart';
import 'commands/init_nav_command.dart';
import 'commands/init_theme_command.dart';
import 'services/init_nav_service.dart';
import 'commands/init_command.dart';
import 'commands/create_command.dart';
import 'commands/create_screen_command.dart';
import 'generator/cubit_generator.dart';
import 'generator/model_generator.dart';
import 'generator/repository_generator.dart';
import 'services/init_theme_service.dart';
import 'services/inti_service.dart';
import 'services/create_service.dart';
import 'services/run_service.dart';
import 'services/create_screen_service.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // SERVICES
  // Singleton: Just one instance
  sl.registerLazySingleton(() => BuildService());
  sl.registerLazySingleton(() => InitNavService());
  sl.registerLazySingleton(() => CreateScreenService());
  sl.registerLazySingleton(() => InitThemeService());

  sl.registerLazySingleton(
    () => CreateService(
      modelGenerator: sl(), // get_it will pass the instance auto
      repositoryGenerator: sl(),
      cubitGenerator: sl(),
      runServiceFactory:
          ({
            required Map<String, dynamic> config,
            required String outputDir,
            required String packageName,
            required String featureName,
          }) => RunService(
            featureName: featureName,
            config: config,
            outputDir: outputDir,
            packageName: packageName,
          ),
    ),
  );

  /* GENERATORS
   LazySingleton:Create the instance when i call it for the firs time then
   keep it until the app die
  */
  sl.registerLazySingleton(() => ModelGenerator());
  sl.registerLazySingleton(() => RepositoryGenerator());
  sl.registerLazySingleton(() => CubitGenerator());

  // COMMANDS
  // Factory: Create instance each time i call it
  sl.registerFactory<BaseCommand>(
    () => BuildCommand(sl()),
    instanceName: 'init',
  );
  sl.registerFactory<BaseCommand>(
    () => InitNavCommand(sl()),
    instanceName: 'init:nav',
  );

  sl.registerFactory<BaseCommand>(
    () => CreateCommand(sl()),
    instanceName: 'create',
  );
  sl.registerFactory<BaseCommand>(
    () => CreateScreenCommand(sl()),
    instanceName: 'create:screen',
  );
  sl.registerFactory<BaseCommand>(
    () => InitThemeCommand(sl()),
    instanceName: 'init:theme',
  );
  // sl.registerFactory<BaseCommand>(
  //   () => InitThemeCommand(sl()),
  //   instanceName: 'init:theme',
  // );
}
