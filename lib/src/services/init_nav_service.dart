// lib/src/services/init_nav_service.dart

import 'dart:io';
import 'dart:isolate';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as p;

class InitNavService {
  String _templatesDir = 'lib/src/templates';

  Future<void> handle() async {
    print('🚦 Initializing navigation with go_router...');

    await _addGoRouterDependency();
    await _createRouterFiles(); // The orchestrator method
    _printInstructions();

    print('\n✅ Navigation setup is almost complete!');
  }

  // This orchestrator method now mirrors your `generateModels` structure
  Future<void> _createRouterFiles() async {
    print('  -> Creating navigation files...');
    await getPackagePath();
    // Define the files to be created and their content builders
    final filesToCreate = {
      'lib/routes/app_router.dart': _buildAppRouterContent,
      'lib/routes/unknown_page.dart': _buildUnknownPageContent,
      'lib/routes/navigator_observer.dart': _buildNavigatorObserverContent,
      'lib/routes/app_routes.dart': _buildAppRoutesContent,
    };

    filesToCreate.forEach((outputPath, contentBuilder) {
      final fileContent =
          contentBuilder(); // Call the specific builder function

      final file = File(outputPath);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(fileContent);
      print('     - Created $outputPath');
    });
  }

  Future<void> getPackagePath() async {
    final packageUri = Uri.parse('package:w_builder/w_builder.dart');
    final packagePathUri = await Isolate.resolvePackageUri(packageUri);
    if (packagePathUri == null) {
      print('❌ Error: Could not resolve package path. Cannot copy core files.');
      return;
    }
    print(packagePathUri.toFilePath());
    final cliRootDir = p.dirname(p.dirname(packagePathUri.toFilePath()));

    final sourceDir = Directory(p.join(cliRootDir, 'lib', 'src', 'templates'));
    _templatesDir = sourceDir.path;
  }

  // --- Private Content Builders  ---

  String _buildAppRouterContent() {
    final templatePath = '$_templatesDir/app_router.mustache';
    final templateString = File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);
    // No variables needed, so we pass an empty map
    return template.renderString({});
  }

  String _buildAppRoutesContent() {
    final templatePath = '$_templatesDir/app_routes.mustache';
    final templateString = File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);
    // No variables needed, so we pass an empty map
    return template.renderString({});
  }

  String _buildUnknownPageContent() {
    final templatePath = '$_templatesDir/unknown_page.mustache';
    final templateString = File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);
    return template.renderString({});
  }

  String _buildNavigatorObserverContent() {
    final templatePath = '$_templatesDir/navigator_observer.mustache';
    final templateString = File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);
    return template.renderString({});
  }

  // --- Other Helper Methods ---

  Future<void> _addGoRouterDependency() async {
    print('  -> Adding go_router dependency...');
    final result = await Process.run('dart', ['pub', 'add', 'go_router']);
    if (result.exitCode != 0) {
      print('  ❌ Failed to add go_router: ${result.stderr}');
    } else {
      print('  ✅ go_router added successfully.');
    }
  }

  void _printInstructions() {
    // This method remains the same as before
    print('\n------------------- MANUAL STEPS REQUIRED -------------------');
    print(
      'Nearly there! Please complete the setup by editing your `lib/main.dart` file:\n',
    );
    print('1. Add this import to the top of the file:');
    print(
      '   \x1B[36mimport \'package:YOUR_PROJECT_NAME/routes/app_router.dart\';\x1B[0m',
    );
    print('\n2. Find your `MaterialApp` widget.');
    print('3. Change `MaterialApp` to `MaterialApp.router`.');
    print('4. REMOVE the `home:` property.');
    print('5. ADD the `routerConfig:` property like this:\n');
    print(
      '   \x1B[32m MaterialApp.router(\n     routerConfig: AppRouter.router,\n     // ... other properties like theme, title, etc.\n   )\x1B[0m',
    );
    print('-----------------------------------------------------------');
  }
}
