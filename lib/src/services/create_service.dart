import 'dart:convert';
import 'dart:io';
import 'run_service.dart';

import '../utils/file_writer.dart';
import '../generator/model_generator.dart';
import '../generator/repository_generator.dart';
import '../generator/cubit_generator.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'package:path/path.dart' as p;

typedef RunServiceFactory =
    RunService Function({
      required Map<String, dynamic> config,
      required String outputDir,
      required String packageName,
    });

class CreateService {
  final ModelGenerator _modelGenerator;
  final RepositoryGenerator _repositoryGenerator;
  final CubitGenerator _cubitGenerator;
  final RunServiceFactory _runServiceFactory;

  // Constructor جديد يقبل التبعيات
  CreateService({
    required ModelGenerator modelGenerator,
    required RepositoryGenerator repositoryGenerator,
    required CubitGenerator cubitGenerator,
    required RunServiceFactory runServiceFactory,
  }) : _modelGenerator = modelGenerator,
       _repositoryGenerator = repositoryGenerator,
       _cubitGenerator = cubitGenerator,
       _runServiceFactory = runServiceFactory;

  Future<void> handleCreateCommand(String filePath) async {
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
    print('✅ Project name identified: $packageName');
    //Reading JSON file
    print('✨ Reading configuration from: $filePath');
    final file = File(filePath);

    if (!file.existsSync()) {
      print('Error: File not found at path: $filePath');
      exit(1);
    }

    try {
      final content = file.readAsStringSync();
      final jsonConfig = jsonDecode(content) as Map<String, dynamic>;
      print('✅ JSON file parsed successfully!');
      print('Feature Name: ${jsonConfig['feature_name']}');
      print('---');
      generateCode(jsonConfig, filePath, packageName);
    } on FormatException catch (e) {
      print('Error: Invalid JSON format in $filePath');
      print(e.message);
      exit(1);
    } catch (e) {
      print('An unexpected error occurred: $e');
      exit(1);
    }
  }

  void generateCode(
    Map<String, dynamic> config,
    String filePath,
    String packageName,
  ) async {
    //handling path
    String directoryPath = p.dirname(filePath);
    //Model generator
    final modelFiles = await _modelGenerator.generateModels(
      config,
      directoryPath,
    );
    if (modelFiles.isEmpty) {
      print('🟡 No models found to generate.');
    } else {
      for (final modelFile in modelFiles) {
        writeFile(path: modelFile.path, content: modelFile.content);
      }
    }
    //Repo generator
    final repositoryFile = await _repositoryGenerator.generateRepository(
      config,
      directoryPath,
      packageName,
    );
    writeFile(path: repositoryFile.path, content: repositoryFile.content);
    //Cubit generator
    final cubitFile = await _cubitGenerator.generateCubit(
      config,
      directoryPath,
      packageName,
    );
    writeFile(path: cubitFile.path, content: cubitFile.content);
    final runService = _runServiceFactory(
      config: config,
      outputDir: directoryPath,
      packageName: packageName,
    );
    //Endpoint & injection & build runner
    runService.updateEndPointsFile();
    runService.updateServiceLocatorFile();
    runService.runBuildRunner();
  }
}
