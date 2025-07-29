// lib/src/generators/cubit_generator.dart

import 'dart:io';
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart' as p;
import 'package:w_builder/src/helper/package_path_getter.dart';
import '../helper/string_helper.dart';
import 'model_generator.dart';

class CubitGenerator {
  Future<List<GeneratedFile>> generateCubit(
    String featureName,
    Map<String, dynamic> apiConfig,
    String outputDir,
    String packageName,
  ) async {
    // --- 1. Common Data Extraction ---
    final apiNamePascal = (apiConfig['name'] as String).toPascalCase();
    final apiNameCamel = (apiConfig['name'] as String).toCamelCase();
    final apiNameSnake = (apiConfig['name'] as String).toSnakeCase();

    final cubitClassName = '${apiNamePascal}Cubit';
    final stateClassName = '${apiNamePascal}State';
    final cubitFileName = '${apiNameSnake}_cubit.dart';
    final stateFileName = '${apiNameSnake}_state.dart';
    final apiDirName = '${apiNameSnake}_cubit';

    final repositoryClassName = '${featureName.toPascalCase()}Repository';
    final isPagination = apiConfig['pagination'] ?? false;

    final responseModelConfig =
        apiConfig['response_model'] ??
        (apiConfig['list_response_model'] as List).first;
    final responseModelName = responseModelConfig['name'] as String;
    final successDataModel = isPagination
        ? 'PaginationModel<$responseModelName>'
        : responseModelName;

    // --- 2. Generate State File (This is common for both cases) ---
    final stateFile = await _generateStateFile(
      outputDir: outputDir,
      apiDirName: apiDirName,
      stateFileName: stateFileName,
      cubitFileName: cubitFileName,
      stateClassName: stateClassName,
      successDataModel: successDataModel,
    );

    // --- 3. Generate Cubit File (Conditional Logic) ---
    final cubitFile = await _generateCubitFile(
      packageName: packageName,
      featureName: featureName,
      outputDir: outputDir,
      apiConfig: apiConfig,
      apiDirName: apiDirName,
      apiNamePascal: apiNamePascal,
      apiNameCamel: apiNameCamel,
      isPagination: isPagination,
      cubitClassName: cubitClassName,
      stateClassName: stateClassName,
      cubitFileName: cubitFileName,
      stateFileName: stateFileName,
      repositoryClassName: repositoryClassName,
      responseModelName: responseModelName,
    );

    return [stateFile, cubitFile];
  }

  // Private helper to generate the state file
  Future<GeneratedFile> _generateStateFile({
    required String outputDir,
    required String apiDirName,
    required String stateFileName,
    required String cubitFileName,
    required String stateClassName,
    required String successDataModel,
  }) async {
    final stateTemplatePath = p.join(
      await getPackagePath('templates'),
      'cubit_state.mustache',
    );
    final template = Template(
      await File(stateTemplatePath).readAsStringSync(),
      htmlEscapeValues: false,
    );
    final content = template.renderString({
      'cubit_file_name': cubitFileName.split('.').first,
      'state_class_name': stateClassName,
      'success_data_model': successDataModel,
    });
    return GeneratedFile(
      path: p.join(outputDir, 'cubits', apiDirName, stateFileName),
      content: content,
    );
  }

  // Private helper to generate the cubit file with conditional logic
  Future<GeneratedFile> _generateCubitFile({
    required String packageName,
    required String featureName,
    required String outputDir,
    required Map<String, dynamic> apiConfig,
    required String apiDirName,
    required String apiNamePascal,
    required String apiNameCamel,
    required bool isPagination,
    required String cubitClassName,
    required String stateClassName,
    required String cubitFileName,
    required String stateFileName,
    required String repositoryClassName,
    required String responseModelName,
  }) async {
    // --- Determine template and prepare specific data ---
    final String templateName;
    final Map<String, dynamic> renderData = {};
    final imports = <String>{
      "import '../../models/${responseModelName.toSnakeCase()}.dart';",
    };
    final repoCallArgs = <String>[];

    if (isPagination) {
      templateName = 'pagination_cubit.mustache';
      final fieldsToStore = <String>[];
      repoCallArgs.add('page: pageKey');

      if (apiConfig['body'] != null) {
        final bodyModelName = '${apiNamePascal}RequestBodyModel';
        fieldsToStore.add('late final $bodyModelName _body;');
        imports.add(
          "import '../../models/${bodyModelName.toSnakeCase()}.dart';",
        );
        repoCallArgs.add('body: _body');
      }
      if (apiConfig['query_parameters'] != null) {
        for (final param in apiConfig['query_parameters'] as List) {
          if (param['name'] == 'page') continue;
          fieldsToStore.add(
            'late final ${param['type']} _${(param['name'] as String).toCamelCase()};',
          );
          repoCallArgs.add(
            '${(param['name'] as String).toCamelCase()}: _${(param['name'] as String).toCamelCase()}',
          );
        }
      }
      renderData['fields_to_store'] = fieldsToStore;
      renderData['response_model'] = responseModelName;
      renderData['response_model_snake'] = responseModelName.toSnakeCase();
    } else {
      // Standard Cubit
      templateName = 'cubit.mustache';
      final methodArgs = <Map<String, String>>[];
      if (apiConfig['body'] != null) {
        final bodyModelName = '${apiNamePascal}RequestBodyModel';
        methodArgs.add({'type': bodyModelName, 'name': 'body'});
        imports.add(
          "import '../../models/${bodyModelName.toSnakeCase()}.dart';",
        );
        repoCallArgs.add('body: body');
      }
      if (apiConfig['query_parameters'] != null) {
        for (final param in apiConfig['query_parameters'] as List) {
          final paramName = (param['name'] as String).toCamelCase();
          methodArgs.add({'type': param['type'], 'name': paramName});
          repoCallArgs.add("$paramName: $paramName");
        }
      }
      renderData['method_args'] = methodArgs;
      renderData['has_args'] = methodArgs.isNotEmpty;
    }

    // --- Add common data and render template ---
    renderData.addAll({
      'package_name': packageName,
      'feature_name': featureName,
      'feature_name_snake': featureName.toSnakeCase(),
      'imports': imports
          .map(
            (e) => e
                .replaceAll('{{package_name}}', packageName)
                .replaceAll('{{feature_name}}', featureName),
          )
          .toList(),
      'state_file_name': stateFileName,
      'cubit_file_name': cubitFileName.split('.').first,
      'cubit_class_name': cubitClassName,
      'state_class_name': stateClassName,
      'repository_class_name': repositoryClassName,
      'method_name': apiNameCamel,
      'method_name_in_repo': apiNameCamel,
      'repo_call_args': repoCallArgs,
    });

    final templatePath = p.join(
      await getPackagePath('templates'),
      templateName,
    );
    final template = Template(
      await File(templatePath).readAsStringSync(),
      htmlEscapeValues: false,
    );
    final content = template.renderString(renderData);

    return GeneratedFile(
      path: p.join(outputDir, 'cubits', apiDirName, cubitFileName),
      content: content,
    );
  }
}
