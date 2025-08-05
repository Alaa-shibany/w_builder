// lib/common/utils/state_handler.dart

import 'package:flutter/material.dart';
import '../../services/failure_service/failure.dart';
import '../../services/status.dart';
import '../../shared/dialogs/loading_dialog.dart';

void handleSubmissionState({
  required BuildContext context,
  required SubmissionStatus state,
  required Failure failure,
  required VoidCallback onSuccess,
  bool isShimmer = false,
  required void Function()? onRetryPressed,
}) {
  if (state == SubmissionStatus.loading && !isShimmer) {
    showLoadingDialog(context);
  } else if (state == SubmissionStatus.error) {
    failure.handle(context, onRetry: () {});
  } else if (state == SubmissionStatus.success) {
    if (isShimmer) {
      Navigator.of(context).pop();
    }
    onSuccess();
  }
}
