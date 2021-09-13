import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title, message;
  final String? confirmText, cancelText;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(false),
          child: Text(cancelText ?? "Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(true),
          child: Text(confirmText ?? "Confirm"),
        )
      ],
    );
  }

  static Future<bool> show(BuildContext context, String title, String message,
      {confirmText, cancelText}) async {
    final result = await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
          ),
        ) ??
        false;

    return result;
  }
}
