import 'package:flutter/widgets.dart';
import '../failure_service/failure.dart';
import '../../shared/dialogs/error_dialog.dart';

class GenericFailureFactory extends Failure {
  GenericFailureFactory(super.message);

  @override
  Future<void> handle(BuildContext context, {void Function()? onRetry}) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    showErrorDialog(context, message);
  }
}
