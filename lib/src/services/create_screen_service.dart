import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mustache_template/mustache.dart';
import '../di_container.dart';
import '../helper/string_helper.dart';
import 'init_nav_service.dart';
import 'package:yaml/yaml.dart' as yaml;

class CreateScreenService {
  final String _templatesDir = 'lib/src/templates';

  Future<void> handle(String screenName) async {
    print('✨ Creating a new screen: $screenName');

    // 1. Check for navigation setup and run it if needed
    await _checkAndRunNavInit();

    // 2. Create directory structure
    final featureDir = _createDirectoryStructure(screenName);

    // 3. Create files from templates
    _createFiles(screenName, featureDir);

    // 4. Add route to router files
    _addRoute(screenName);

    print('\n✅ Screen "$screenName" created successfully!');
  }

  Future<void> _checkAndRunNavInit() async {
    final routesFile = File(p.join('lib', 'routes', 'app_router.dart'));

    print("DEBUG: Checking for file at '${routesFile.absolute.path}'...");

    if (routesFile.existsSync()) {
      print("DEBUG: File found. Skipping 'init:nav'.");
    } else {
      print("DEBUG: File NOT found. Running 'init:nav'...");
      final navService = sl<InitNavService>();
      await navService.handle();
      print('---'); // Separator
    }
  }

  String _createDirectoryStructure(String screenName) {
    print('  -> Creating directory structure...');
    final featureDir = Directory(
      p.join('lib', 'features', screenName.toSnakeCase()),
    );
    final subDirs = [
      'repo',
      'cubits',
      'models',
      'presentation',
      p.join('presentation', 'components'),
    ];

    for (var dirName in subDirs) {
      final fullPath = Directory(p.join(featureDir.path, dirName));
      fullPath.createSync(recursive: true);
    }
    print('     - Created directories in ${featureDir.path}');
    return featureDir.path;
  }

  void _createFiles(String screenName, String featureDir) {
    print('  -> Creating screen and config files...');
    final screenNameSnake = screenName.toSnakeCase();

    // Data for templates
    final templateData = {
      'screenNamePascalCase': screenName.toPascalCase(),
      'screenNameTitleCase': screenName.toTitleCase(),
      'screenNameSnakeCase': screenNameSnake,
    };

    // Create Screen file
    final screenContent = _renderTemplate('screen.mustache', templateData);
    final screenPath = p.join(
      featureDir,
      'presentation',
      '${screenNameSnake}_screen.dart',
    );
    File(screenPath).writeAsStringSync(screenContent);
    print('     - Created $screenPath');

    // Create Config file
    final configContent = _renderTemplate('config.mustache', templateData);
    final configPath = p.join(featureDir, 'config.json');
    File(configPath).writeAsStringSync(configContent);
    print('     - Created $configPath');
  }

  void _addRoute(String screenName) {
    print('  -> Adding route to navigation files...');
    final screenNameSnake = screenName.toSnakeCase();
    final screenNameCamel = screenName.toCamelCase();
    final screenNamePascal = screenName.toPascalCase();

    // Add to app_routes.dart
    final appRoutesFile = File('lib/routes/app_routes.dart');
    String routesContent = appRoutesFile.readAsStringSync();
    final newRoute =
        "  static const String $screenNameCamel = '/$screenNameSnake';";
    routesContent = routesContent.replaceFirst(
      '//<-- DONT_REMOVE_THIS_LINE_ROUTES -->',
      '$newRoute\n  //<-- DONT_REMOVE_THIS_LINE_ROUTES -->',
    );
    appRoutesFile.writeAsStringSync(routesContent);
    print('     - Updated lib/routes/app_routes.dart');

    // Add to app_router.dart
    final appRouterFile = File('lib/routes/app_router.dart');
    String routerContent = appRouterFile.readAsStringSync();
    final newGoRoute =
        """
      GoRoute(
        name: '$screenNameCamel',
        path: AppRoutes.$screenNameCamel,
        builder: (context, state) => const ${screenNamePascal}Screen(),
      ),
""";
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('❌ Error: pubspec.yaml not found in the project root.');
      print(
        'Please run the command from within a feature folder inside your project.',
      );
      exit(1);
    }
    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspecYaml = yaml.loadYaml(pubspecContent) as yaml.YamlMap;
    final packageName = pubspecYaml['name'] as String;
    final importStatement =
        "import 'package:$packageName/features/$screenNameSnake/presentation/${screenNameSnake}_screen.dart';";

    // Add import
    routerContent = routerContent.replaceFirst(
      "import 'navigator_observer.dart';",
      "import 'navigator_observer.dart';\n$importStatement",
    );
    // Add GoRoute
    routerContent = routerContent.replaceFirst(
      '//<-- DONT_REMOVE_THIS_LINE_GOROUTES -->',
      '$newGoRoute\n      //<-- DONT_REMOVE_THIS_LINE_GOROUTES -->',
    );
    appRouterFile.writeAsStringSync(routerContent);
    print('     - Updated lib/routes/app_router.dart');
    print(
      '     🟡 NOTE: Please replace "YOUR_PROJECT_NAME" in the new import statement in app_router.dart',
    );
  }

  String _renderTemplate(String templateName, Map<String, dynamic> data) {
    final templatePath = p.join(_templatesDir, templateName);
    final templateString = File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);
    return template.renderString(data);
  }
}
