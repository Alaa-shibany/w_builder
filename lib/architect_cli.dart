import 'package:package_info_plus/package_info_plus.dart';

int calculate() {
  PackageInfo.fromPlatform().then((value) {
    print(
      value.data,
    ); // Value will be our all details we get from package info package
    print('......................');
    print(value);
  });
  print("hello");
  return 6 * 7;
}
