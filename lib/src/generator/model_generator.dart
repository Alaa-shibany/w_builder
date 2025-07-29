// lib/src/generators/model_generator.dart

import 'dart:io';

import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as p;
import 'package:w_builder/src/helper/package_path_getter.dart';

import '../helper/string_helper.dart';

// GeneratedFile class remains the same
class GeneratedFile {
  final String path;
  final String content;

  GeneratedFile({required this.path, required this.content});
}

class ModelGenerator {
  Future<List<GeneratedFile>> generateModels(
    Map<String, dynamic> config,
    String jsonFilePath,
  ) async {
    final filesToCreate = <GeneratedFile>[];
    final modelsToProcess = <Map<String, dynamic>>[];
    final featureName = config['name'] as String;
    //Handling body and convert it to model
    if (config['body'] != null) {
      final bodyFields = config['body'] as Map<String, dynamic>;
      final fieldsList = bodyFields.entries.map((entry) {
        return {'name': entry.key, 'type': entry.value};
      }).toList();
      final requestBodyModelConfig = {
        'name': '${featureName}RequestBodyModel',
        'fields': fieldsList,
      };
      modelsToProcess.add(requestBodyModelConfig);
    }

    //Check if i have one model or List of models
    if (config['response_model'] != null) {
      modelsToProcess.add(config['response_model'] as Map<String, dynamic>);
    }
    if (config['list_response_model'] != null) {
      final modelList = config['list_response_model'] as List<dynamic>;
      modelsToProcess.addAll(modelList.cast<Map<String, dynamic>>());
    }

    //Get all models name
    final allModelNames = modelsToProcess
        .map((m) => m['name'] as String)
        .toList();

    for (final modelConfig in modelsToProcess) {
      final fileContent = _buildModelContent(modelConfig, allModelNames);

      final modelName = modelConfig['name'] as String;
      final filePath = '$jsonFilePath/models/${modelName.toSnakeCase()}.dart';

      filesToCreate.add(
        GeneratedFile(path: filePath, content: await fileContent),
      );
    }

    return filesToCreate;
  }

  Future<String> _buildModelContent(
    Map<String, dynamic> modelConfig,
    List<String> allModelNames,
  ) async {
    final modelName = (modelConfig['name'] as String).toPascalCase();
    final modelFields = modelConfig['fields'] as List<dynamic>;
    final fileName = modelName.toSnakeCase();

    final imports = <String>[];

    final fields = modelFields.map((field) {
      final f = field as Map<String, dynamic>;
      final name = f['name'] as String;
      final type = f['type'] as String;
      final jsonKey = f.containsKey('json_key')
          ? f['json_key'] as String
          : null;

      for (final otherModel in allModelNames) {
        if (type.contains(otherModel) && otherModel != modelName) {
          final importPath = '${otherModel.toSnakeCase()}.dart';
          if (!imports.contains(importPath)) {
            imports.add(importPath);
          }
        }
      }

      return {'name': name, 'type': type, 'json_key': jsonKey};
    }).toList();

    final templatePath = Directory(
      p.join(await getPackagePath('templates'), 'model.mustache'),
    );
    final templateString = File(templatePath.path).readAsStringSync();

    final template = Template(templateString, htmlEscapeValues: false);

    final rendered = template.renderString({
      'model_name': modelName,
      'file_name': fileName,
      'imports': imports,
      'fields': fields,
    });

    return rendered;
  }
}
