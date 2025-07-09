// lib/src/generators/cubit_generator.dart

import 'package:w_builder/src/helper/package_path_getter.dart';

import 'model_generator.dart';
import '../helper/string_helper.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:mustache_template/mustache_template.dart';

class CubitGenerator {
  Future<GeneratedFile> generateCubit(
    Map<String, dynamic> config,
    String outputDir,
    String packageName,
  ) async {
    final featureName = config['feature_name'] as String;
    final bool isPagination = config['pagination'] ?? false;

    //Build depend on request type
    final String content = isPagination
        ? await _buildPaginationCubitContent(config, packageName)
        : await _buildStandardCubitContent(config, packageName);

    final filePath = p.join(
      outputDir,
      'cubit',
      '${featureName.toSnakeCase()}_cubit.dart',
    );

    return GeneratedFile(path: filePath, content: content);
  }

  //Stander
  Future<String> _buildStandardCubitContent(
    Map<String, dynamic> config,
    String packageName,
  ) async {
    final featureName = config['feature_name'] as String;
    final cubitClassName = '${featureName}Cubit';
    final repositoryClassName = '${featureName}Repository';
    final requestType = (config['request_type'] as String).toLowerCase();
    final methodName = '$requestType${featureName}Data';
    final responseModelConfig =
        config['response_model'] ??
        (config['list_response_model'] as List).first;
    final responseModelName = responseModelConfig['name'] as String;
    final responseModelSnake = responseModelName.toSnakeCase();

    final imports = <String>[];
    final methodArgs = <Map<String, String>>[];
    final repoCallArgs = <String>[];

    if (config['body'] != null) {
      final bodyModelName = '${featureName}RequestBodyModel';
      methodArgs.add({'type': bodyModelName, 'name': 'body'});
      imports.add("import '../models/${bodyModelName.toSnakeCase()}.dart';");
      repoCallArgs.add('body: body');
    }
    if (config['query_parameters'] != null) {
      for (final param in config['query_parameters'] as List) {
        methodArgs.add({'type': param['type'], 'name': param['name']});
        repoCallArgs.add("${param['name']}:${param['name']}");
      }
    }

    final templatePath = Directory(
      p.join(await getPackagePath('templates'), 'standard_cubit.mustache'),
    );
    final templateString = File(templatePath.path).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);

    return template.renderString({
      'package_name': packageName,
      'feature_name_snake': featureName.toSnakeCase(),
      'response_model': responseModelName,
      'response_model_snake': responseModelSnake,
      'cubit_class_name': cubitClassName,
      'repository_class_name': repositoryClassName,
      'method_name': methodName,
      'imports': imports,
      'method_args': methodArgs,
      'repo_call_args': repoCallArgs,
      'has_args': methodArgs.isNotEmpty,
    });
  }

  //Pagination
  Future<String> _buildPaginationCubitContent(
    Map<String, dynamic> config,
    String packageName,
  ) async {
    final featureName = config['feature_name'] as String;
    final requestType = (config['request_type'] as String).toLowerCase();
    final methodName = '$requestType${featureName}Data';
    final cubitClassName = '${featureName}Cubit';
    final repositoryClassName = '${featureName}Repository';

    final responseModelName =
        (config['response_model'] ??
                (config['list_response_model'] as List).first)['name']
            as String;

    final imports = <String>[];
    final fieldsToStore = <String>[];
    final methodArgs = <Map<String, String>>[];
    final repoCallArgs = <String>['page: pageKey'];

    if (config['body'] != null) {
      final bodyModelName = '${featureName}RequestBodyModel';
      fieldsToStore.add('$bodyModelName _body');
      methodArgs.add({'type': bodyModelName, 'name': 'body'});
      imports.add("import '../models/${bodyModelName.toSnakeCase()}.dart';");
      repoCallArgs.add('body: _body');
    }

    if (config['query_parameters'] != null) {
      for (final param in config['query_parameters'] as List) {
        if (param['name'] == 'page') continue;
        fieldsToStore.add('${param['type']} _${param['name']}');
        methodArgs.add({'type': param['type'], 'name': param['name']});
        repoCallArgs.add('${param['name']}: _${param['name']}');
      }
    }
    final templatePath = Directory(
      p.join(await getPackagePath('templates'), 'pagination_cubit.mustache'),
    );
    final templateString = File(templatePath.path).readAsStringSync();

    final template = Template(templateString, htmlEscapeValues: false);

    return template.renderString({
      'package_name': packageName,
      'feature_name_snake': featureName.toSnakeCase(),
      'response_model': responseModelName,
      'response_model_snake': responseModelName.toSnakeCase(),
      'cubit_class_name': cubitClassName,
      'repository_class_name': repositoryClassName,
      'method_name': methodName,
      'imports': imports,
      'fields_to_store': fieldsToStore,
      'repo_call_args': repoCallArgs,
    });
  }
}
