import 'dart:io';

import 'package:path/path.dart' as p;

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
      'freezed_annotation',
      'dev:build_runner',
      'dev:freezed',
      'dev:json_serializable',
    ];
    for (final packageName in requiredPackages) {
      await _addDependency(packageName, projectPath);
    }

    print('⚙️ Copying core files...');
    // final scriptPath = Platform.script.toFilePath();
    // final cliRootDir = p.dirname(p.dirname(scriptPath));
    final sourceDir = Directory(p.join(projectPath, 'bin', 'src', 'core'));
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
