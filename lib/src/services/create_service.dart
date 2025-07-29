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
      required String featureName,
    });

class CreateService {
  final ModelGenerator _modelGenerator;
  final RepositoryGenerator _repositoryGenerator;
  final CubitGenerator _cubitGenerator;
  final RunServiceFactory _runServiceFactory;

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
    // --- 1. Extract feature name and list of APIs ---
    String directoryPath = p.dirname(filePath);
    final featureName = config['feature_name'] as String;
    final apis = List<Map<String, dynamic>>.from(config['apis']);

    print('🔄 Generating models');
    // --- 2. Model generator (Assuming it's updated to handle a list) ---
    for (final data in apis) {
      final modelFiles = await _modelGenerator.generateModels(
        data,
        directoryPath,
      );
      for (final modelFile in modelFiles) {
        writeFile(path: modelFile.path, content: modelFile.content);
      }
    }
    print('✅ Models generated successfully!');

    // --- 3. Repo generator (The new call) ---
    print('🔄 Generating single repository for feature: $featureName...');
    final repositoryFile = await _repositoryGenerator.generateRepository(
      featureName: featureName,
      apis: apis,
      outputDir: directoryPath,
      packageName: packageName,
    );
    writeFile(path: repositoryFile.path, content: repositoryFile.content);
    print('✅ Repository generated successfully!');

    // --- 4. Cubit generator (Looping through each API) ---
    for (final apiConfig in apis) {
      final apiName = apiConfig['name'] as String;
      print('🔄 Generating Cubit for API: $apiName...');

      // The new call for each apiConfig
      final cubitFiles = await _cubitGenerator.generateCubit(
        featureName,
        apiConfig,
        directoryPath,
        packageName,
      );
      for (final file in cubitFiles) {
        writeFile(path: file.path, content: file.content);
      }
      print('✅ Cubit for $apiName generated successfully!');
    }
    RunService? runService;
    for (final data in apis) {
      runService = _runServiceFactory(
        featureName: config['feature_name'],
        config: data,
        outputDir: directoryPath,
        packageName: packageName,
      );

      runService.updateEndPointsFile();
      runService.addCubitsServiceLocatorFile();
    }
    runService!.addRepoServiceLocatorFile();
    runService.runBuildRunner();
    // print(
    //   '🟡 NOTE: RunService for endpoints and DI needs to be updated to handle multiple APIs.',
    // );
    print('✨ Code generation process completed.');
  }
}
