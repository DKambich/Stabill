import 'package:flutter/material.dart';
import 'package:stabill/constants.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final Text? confirmText;
  final Text? cancelText;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
  }) : super(key: key);

  static Future<bool> show(
    BuildContext context,
    String title,
    String message, {
    Text? confirmText,
    Text? cancelText,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: dialogShape,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(false),
          child: cancelText ?? const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(true),
          child: confirmText ?? const Text("Confirm"),
        ),
      ],
    );
  }
}
