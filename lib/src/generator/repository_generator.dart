// lib/src/generators/repository_generator.dart

import 'package:w_builder/src/helper/package_path_getter.dart';

import 'model_generator.dart';
import '../helper/string_helper.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:mustache_template/mustache_template.dart';

class RepositoryGenerator {
  Future<GeneratedFile> generateRepository(
    Map<String, dynamic> config,
    String outputDir,
    String packageName,
  ) async {
    final featureName = config['feature_name'] as String;
    String endpoint = config['endpoint'] as String;
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    final requestType = (config['request_type'] as String).toLowerCase();
    final isPagination = config['pagination'] ?? false;

    final repositoryClassName = '${featureName}Repository';
    final methodName = '$requestType${featureName}Data';

    final responseModelConfig =
        config['response_model'] ??
        (config['list_response_model'] as List).first;
    final responseModel = responseModelConfig['name'] as String;
    final responseModelFile = '${responseModel.toSnakeCase()}.dart';

    final methodArgs = <Map<String, String>>[];
    final imports = <String>[];
    final queryMap = <String, String>{};
    bool hasBody = false;

    if (config['query_parameters'] != null) {
      for (final param in config['query_parameters'] as List) {
        methodArgs.add({'type': param['type'], 'name': param['name']});
        queryMap["'${param['name']}'"] = param['name'];
      }
    }

    if (config['body'] != null) {
      hasBody = true;
      final bodyModelName = '${featureName}RequestBodyModel';
      methodArgs.add({'type': bodyModelName, 'name': 'body'});
      imports.add("import '../models/${bodyModelName.toSnakeCase()}.dart';");
    }
    final templatePath = Directory(
      p.join(await getPackagePath('templates'), 'repository.mustache'),
    );
    final templateString = File(templatePath.path).readAsStringSync();

    final template = Template(templateString, htmlEscapeValues: false);

    final rendered = template.renderString({
      'package_name': packageName,
      'repository_class_name': repositoryClassName,
      'method_name': methodName,
      'request_type': requestType,
      'endpoint': endpoint,
      'response_model': responseModel,
      'response_model_file': responseModelFile,
      'return_type': isPagination
          ? 'PaginationModel<$responseModel>'
          : responseModel,
      'imports': imports,
      'method_args': methodArgs,
      'has_args': methodArgs.isNotEmpty,
      'query_map': queryMap,
      'has_query': queryMap.isNotEmpty,
      'has_body': hasBody,
      'is_pagination': isPagination,
    });

    final filePath = p.join(
      outputDir,
      'repo',
      '${featureName.toSnakeCase()}_repository.dart',
    );

    return GeneratedFile(path: filePath, content: rendered);
  }
}
