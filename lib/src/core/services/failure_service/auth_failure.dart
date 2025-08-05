import 'package:flutter/widgets.dart';
import '../../services/failure_service/failure.dart';
import '../../shared/dialogs/login_dialog.dart';

class AuthFailure extends Failure {
  AuthFailure(super.message);

  @override
  Future<void> handle(BuildContext context, {void Function()? onRetry}) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    showLoginRequiredDialog(context, () {});
  }
}
