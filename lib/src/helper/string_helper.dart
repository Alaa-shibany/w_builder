// lib/src/helpers/string_helpers.dart

extension StringCasingExtension on String {
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => '_${m.group(0)}',
    ).toLowerCase();
  }

  /// Converts a string to `PascalCase`.
  /// Example: "hello world" -> "HelloWorld"
  String toPascalCase() {
    if (isEmpty) return '';
    return split(RegExp(r'[ _-]'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  /// Converts a string to `camelCase`.
  /// Example: "hello world" -> "helloWorld"
  String toCamelCase() {
    if (isEmpty) return '';
    final pascal = toPascalCase();
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Converts a string to `Title Case`.
  /// Example: "hello world" -> "Hello World"

  String toTitleCase() {
    if (isEmpty) return '';
    return split(RegExp(r'[ _-]'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
