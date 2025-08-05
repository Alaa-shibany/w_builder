import 'package:flutter/widgets.dart';

abstract class Failure {
  final String message;

  Failure(this.message);

  Future<void> handle(BuildContext context, {void Function()? onRetry});
}
