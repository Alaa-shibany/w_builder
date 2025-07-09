import 'dart:io';

void writeFile({required String path, required String content}) {
  try {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('✅ Created: $path');
  } catch (e) {
    print('❌ Failed to write file: $path');
    print(e);
  }
}
