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
    final parts = _getWords();
    return parts
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  /// Converts a string to `camelCase`.
  /// Example: "hello world" -> "helloWorld"
  String toCamelCase() {
    if (isEmpty) return '';
    final parts = _getWords();
    final firstWord = parts.first.toLowerCase();
    final otherWords = parts
        .skip(1)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase());
    return [firstWord, ...otherWords].join('');
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

  List<String> _getWords() {
    // This regex splits by spaces, underscores, hyphens, and case changes.
    final regExp = RegExp(r'(?<=[a-z])(?=[A-Z])|_|-|\s+');
    return replaceAll(
      regExp,
      ' ',
    ).split(' ').where((s) => s.isNotEmpty).toList();
  }
}
