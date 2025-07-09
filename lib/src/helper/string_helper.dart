// lib/src/helpers/string_helpers.dart

extension StringCasingExtension on String {
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => '_${m.group(0)}',
    ).toLowerCase();
  }
}
