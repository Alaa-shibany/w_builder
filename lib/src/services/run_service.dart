import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:w_builder/src/helper/string_helper.dart';

class RunService {
  final Map<String, dynamic> _config;
  final String _outputDir;
  final String packageName;
  late final String _featureName;
  late final String _endpoint;
  final String featureName;

  RunService({
    required Map<String, dynamic> config,
    required String outputDir,
    required this.packageName,
    required this.featureName,
  }) : _config = config,
       _outputDir = outputDir {
    _featureName = _config['name'] as String;
    _endpoint = _config['endpoint'] as String;
  }

  void updateEndPointsFile() {
    final filePath = p.join('lib', 'core', 'services', 'end_points.dart');
    final file = File(filePath);

    if (!file.existsSync()) {
      print('🟡 Warning: EndPoints file not found at $filePath. Skipping.');
      return;
    }

    String content = file.readAsStringSync();
    final newEndpoint =
        "  static const String ${_endpoint.split('/').join('_')} = '$_endpoint';";

    final lastBraceIndex = content.lastIndexOf('}');
    if (lastBraceIndex != -1) {
      content = content.substring(0, lastBraceIndex) + '$newEndpoint\n}\n';
      file.writeAsStringSync(content);
      print('✅ Injected endpoint: $_featureName');
    }
  }

  void addRepoServiceLocatorFile() {
    final filePath = p.join('lib', 'core', 'services', 'service_locator.dart');
    final file = File(filePath);
    if (!file.existsSync()) {
      print(
        '🟡 Warning: Service Locator file not found at $filePath. Skipping.',
      );
      return;
    }
    List<String> pathSegments = _outputDir.split('/');
    print(pathSegments);
    String mainPath =
        'package:$packageName/${pathSegments.sublist(1).join('/')}';
    print('THE MAIN PATH IS => $mainPath');

    final importStatements =
        """
import '${mainPath}repo/${featureName.toSnakeCase()}_repository.dart';
""";

    final repositoryInjection =
        "  sl.registerLazySingleton(() => ${featureName}Repository(sl()));";

    String content = file.readAsStringSync();

    content = '$importStatements\n$content';

    final injectionPoint = content.lastIndexOf('}');
    if (injectionPoint != -1) {
      content =
          '${content.substring(0, injectionPoint)}$repositoryInjection\n}\n';
      file.writeAsStringSync(content);
      print('✅ Injected dependencies for: $_featureName');
    }
  }

  void addCubitsServiceLocatorFile() {
    final filePath = p.join('lib', 'core', 'services', 'service_locator.dart');
    final file = File(filePath);
    if (!file.existsSync()) {
      print(
        '🟡 Warning: Service Locator file not found at $filePath. Skipping.',
      );
      return;
    }
    List<String> pathSegments = _outputDir.split('/');
    String mainPath =
        'package:$packageName/${pathSegments.sublist(1).join('/')}';
    print('THE MAIN PATH IS => $mainPath');
    final featureSnakeCase = _featureName.toSnakeCase();

    final importStatements =
        """
import '${mainPath}cubits/${featureSnakeCase}_cubit/${featureSnakeCase}_cubit.dart';
""";

    final cubitInjection =
        "  sl.registerFactory(() => ${_featureName.toPascalCase()}Cubit(sl()));";

    String content = file.readAsStringSync();

    content = '$importStatements\n$content';

    final injectionPoint = content.lastIndexOf('}');
    if (injectionPoint != -1) {
      content = '${content.substring(0, injectionPoint)}$cubitInjection\n}\n';
      file.writeAsStringSync(content);
      print('✅ Injected dependencies for: $_featureName');
    }
  }

  Future<void> runBuildRunner() async {
    print('⚙️ Running build_runner... (This may take a moment)');
    String command;
    List<String> args;
    if (Platform.isWindows) {
      command = 'cmd';
      args = [
        '/c',
        'flutter',
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ];
    } else {
      command = 'flutter';
      args = [
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ];
    }
    final result = await Process.run(command, args, workingDirectory: '.');

    if (result.exitCode == 0) {
      print('✅ build_runner completed successfully.');
    } else {
      print('❌ build_runner failed.');
      print('Error: ${result.stderr}');
    }
  }
}
