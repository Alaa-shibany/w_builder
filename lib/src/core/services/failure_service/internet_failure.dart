import 'package:flutter/widgets.dart';
import 'package:w_builder/src/core/services/failure_service/failure.dart';
import 'package:w_builder/src/core/shared/dialogs/internet_dialog.dart';

class InternetFailure extends Failure {
  InternetFailure(super.message);

  @override
  Future<void> handle(BuildContext context, {void Function()? onRetry}) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    showNoInternetDialog(context, onRetry);
  }
}
