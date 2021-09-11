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
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? "Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText ?? "Confirm"),
        )
      ],
    );
  }
}
