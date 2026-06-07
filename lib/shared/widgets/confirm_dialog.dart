import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Shows a confirmation dialog and returns true if confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(AppStrings.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
