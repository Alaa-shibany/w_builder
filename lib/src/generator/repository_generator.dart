// lib/src/generators/repository_generator.dart

import 'dart:io';
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart' as p;
import 'package:w_builder/src/helper/package_path_getter.dart';
import '../helper/string_helper.dart';
import 'model_generator.dart';

//This code will generate one repo and put all CRUD functions in it
class RepositoryGenerator {
  Future<GeneratedFile> generateRepository({
    required String featureName,
    required List<Map<String, dynamic>> apis,
    required String outputDir,
    required String packageName,
  }) async {
    final repositoryClassName = '${featureName.toPascalCase()}Repository';
    final methodsData = <Map<String, dynamic>>[];
    final imports = <String>{};
    bool isPaginationGlobal = false;

    for (final api in apis) {
      final endpoint = (api['endpoint'] as String).startsWith('/')
          ? (api['endpoint'] as String).substring(1).split('/').join('_')
          : (api['endpoint'] as String).split('/').join('_');

      final requestType = (api['request_type'] as String).toLowerCase();
      final isPagination = api['pagination'] ?? false;
      if (isPagination) isPaginationGlobal = true;

      final responseModelConfig =
          api['response_model'] ?? (api['list_response_model'] as List).first;
      final responseModelName = responseModelConfig['name'] as String;

      imports.add(
        "import '../models/${responseModelName.toSnakeCase()}.dart';",
      );

      final methodArgs = <Map<String, String>>[];
      final queryMapEntries = <String>[];
      bool hasBody = false;

      if (api['query_parameters'] != null) {
        for (final param in api['query_parameters'] as List) {
          final paramName = (param['name'] as String).toCamelCase();
          methodArgs.add({'type': param['type'], 'name': paramName});
          queryMapEntries.add("'${param['name']}': $paramName");
        }
      }

      if (api['body'] != null) {
        hasBody = true;
        final bodyModelName =
            '${(api['name'] as String).toPascalCase()}RequestBodyModel';
        methodArgs.add({'type': bodyModelName, 'name': 'body'});
        imports.add("import '../models/${bodyModelName.toSnakeCase()}.dart';");
      }

      // --- Assemble data for this specific method ---
      methodsData.add({
        'method_name': (api['name'] as String).toCamelCase(),
        'request_type': requestType,
        'endpoint': endpoint,
        'response_model': responseModelName,
        'return_type': isPagination
            ? 'PaginationModel<$responseModelName>'
            : responseModelName,
        'is_pagination': isPagination,
        'has_args': methodArgs.isNotEmpty,
        'method_args': methodArgs,
        'has_query': queryMapEntries.isNotEmpty,
        'query_map': '{${queryMapEntries.join(', ')}}',
        'has_body': hasBody,
      });
    }

    // --- Template Rendering ---
    final templatePath = p.join(
      await getPackagePath('templates'),
      'repository.mustache',
    );
    final templateString = await File(templatePath).readAsStringSync();
    final template = Template(templateString, htmlEscapeValues: false);

    final rendered = template.renderString({
      'package_name': packageName,
      'repository_class_name': repositoryClassName,
      'imports': imports.map((e) => e).toList(), // Convert Set to List
      'is_pagination_global': isPaginationGlobal,
      'methods': methodsData, // Pass the list of methods to the template
    });

    final filePath = p.join(
      outputDir,
      'repo',
      '${featureName.toSnakeCase()}_repository.dart',
    );

    return GeneratedFile(path: filePath, content: rendered);
  }
}
