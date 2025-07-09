import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

Future<String> getPackagePath(String folderName) async {
  final packageUri = Uri.parse('package:w_builder/w_builder.dart');
  final packagePathUri = await Isolate.resolvePackageUri(packageUri);
  if (packagePathUri == null) {
    print('❌ Error: Could not resolve package path. Cannot copy core files.');
    return '';
  }
  print(packagePathUri.toFilePath());
  final cliRootDir = p.dirname(p.dirname(packagePathUri.toFilePath()));

  final sourceDir = Directory(p.join(cliRootDir, 'lib', 'src', 'templates'));
  return sourceDir.path;
}
