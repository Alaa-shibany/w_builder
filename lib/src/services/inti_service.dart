import 'dart:io';

import 'package:path/path.dart' as p;
import 'dart:isolate';

class BuildService {
  Future<void> handleBuildCommand(String projectPath) async {
    print('🛠️ Building project structure...');

    print('⚙️ Adding required dependencies...');
    final requiredPackages = [
      'dartz',
      'infinite_scroll_pagination',
      'dio',
      'flutter_bloc',
      'get_it',
      'equatable',
      'shared_preferences',
      'freezed_annotation',
      'google_fonts',
      'flutter_animate'
          'dev:build_runner',
      'dev:freezed',
      'dev:json_serializable',
    ];
    for (final packageName in requiredPackages) {
      await _addDependency(packageName, projectPath);
    }

    print('⚙️ Copying core files...');

    final packageUri = Uri.parse('package:w_builder/w_builder.dart');
    final packagePathUri = await Isolate.resolvePackageUri(packageUri);
    if (packagePathUri == null) {
      print('❌ Error: Could not resolve package path. Cannot copy core files.');
      return;
    }
    print(packagePathUri.toFilePath());
    final cliRootDir = p.dirname(p.dirname(packagePathUri.toFilePath()));

    final sourceDir = Directory(p.join(cliRootDir, 'lib', 'src', 'core'));
    print(sourceDir.path);
    print(await sourceDir.exists());
    final destDir = Directory(p.join(projectPath, 'lib', 'core'));
    copyDirectory(sourceDir, destDir);

    final markerFile = File(p.join(projectPath, '.architect_built'));
    markerFile.createSync();

    print('✅ Project built successfully!');
  }

  Future<void> _addDependency(String packageName, String projectPath) async {
    print('  -> Adding $packageName...');
    String command;
    List<String> args;
    if (Platform.isWindows) {
      command = 'cmd';
      args = ['/c', 'flutter', 'pub', 'add', packageName];
    } else {
      command = 'flutter';
      args = ['pub', 'add', packageName];
    }
    final result = await Process.run(
      command,
      args,
      workingDirectory: projectPath,
    );

    if (result.exitCode == 0) {
      print('  ✅ $packageName added successfully.');
    } else {
      print('  ❌ Failed to add $packageName.');
      print(result.stderr);
    }
  }

  void copyDirectory(Directory source, Directory destination) {
    destination.createSync(recursive: true);
    source.listSync(recursive: false).forEach((entity) {
      if (entity is Directory) {
        final newDirectory = Directory(
          p.join(destination.absolute.path, p.basename(entity.path)),
        );
        copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        entity.copySync(p.join(destination.path, p.basename(entity.path)));
      }
    });
  }
}
