import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}
