import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mustache_template/mustache.dart';
import 'package:w_builder/src/helper/package_path_getter.dart';

class InitThemeService {
  Future<void> handle() async {
    print('✨ Initializing Theme setup...');

    final themeDir = _createDirectoryStructure();

    await _createFilesFromTemplates(themeDir);

    await _addHydratedBlocDependency();

    print('\n✅ Theme setup completed successfully!');
    print('   Next steps:');
    print(
      '   1. Add `google_fonts` to your pubspec.yaml: `flutter pub add google_fonts`',
    );
    print(
      '   2. Wrap your `MaterialApp` with `BlocProvider` for `ThemeCubit`.',
    );
    print(
      '   3. Use `HydratedBloc.storage = await HydratedStorage.build(...)` in your main() function.',
    );
    print('''HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await path.getTemporaryDirectory()).path),
  );''');
    print(
      '   4. Set `theme`, `darkTheme`, and `themeMode` properties in `MaterialApp.router`.',
    );
  }

  String _createDirectoryStructure() {
    print('  -> Creating directory structure...');
    final themePath = p.join('lib', 'config', 'theme');
    final themeDir = Directory(themePath);
    themeDir.createSync(recursive: true);
    print('     - Created directory at $themePath');
    return themeDir.path;
  }

  Future<void> _createFilesFromTemplates(String themeDir) async {
    print('  -> Creating theme files...');

    final filesToCreate = {
      'app_colors.mustache': 'app_colors.dart',
      'app_theme.mustache': 'app_theme.dart',
      'theme_cubit.mustache': 'theme_cubit.dart',
    };

    for (var entry in filesToCreate.entries) {
      final templateName = entry.key;
      final outputFileName = entry.value;

      final content = await _renderTemplate(templateName, {});
      final outputPath = p.join(themeDir, outputFileName);
      File(outputPath).writeAsStringSync(content);
      print('     - Created $outputPath');
    }
  }

  Future<void> _addHydratedBlocDependency() async {
    print('  -> Adding `hydrated_bloc` dependency...');
    try {
      final result = await Process.run('flutter', [
        'pub',
        'add',
        'hydrated_bloc',
      ], runInShell: true);
      if (result.exitCode == 0) {
        print('     - Successfully added `hydrated_bloc` to pubspec.yaml.');
      } else {
        print('     ❌ Error adding `hydrated_bloc`:');
        print(result.stderr);
      }
    } catch (e) {
      print('     ❌ An exception occurred while running `flutter pub add`: $e');
      print('     Please add `hydrated_bloc` to your pubspec.yaml manually.');
    }
  }

  Future<String> _renderTemplate(
    String templateName,
    Map<String, dynamic> data,
  ) async {
    final templatePath = p.join(
      await getPackagePath('templates'),
      templateName,
    );
    final templateString = File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);
    return template.renderString(data);
  }
}
