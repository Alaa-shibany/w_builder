import 'dart:io';

void filesDiscover(String path) {
  final directory = Directory(path);
  final List<FileSystemEntity> entities = directory.listSync(recursive: true);
  print('--- Start of Listing ---');
  // 4. المرور على كل كيان وطباعة مساره ونوعه
  for (FileSystemEntity entity in entities) {
    // التحقق من نوع الكيان لطباعة رسالة أوضح
    if (entity is File) {
      print('[File]    ${entity.path}');
    } else if (entity is Directory) {
      print('[Folder]  ${entity.path}');
    }
  }
  print('--- End of Listing ---');
}
