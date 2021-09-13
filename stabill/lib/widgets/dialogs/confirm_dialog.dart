import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title, message;
  final String? confirmText, cancelText;
  final Color? confirmColor, cancelColor;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.confirmColor,
    this.cancelText,
    this.cancelColor,
  }) : super(key: key);

  static Future<bool> show(
    BuildContext context,
    String title,
    String message, {
    confirmText,
    confirmColor,
    cancelText,
    cancelColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        confirmColor: confirmColor,
        cancelText: cancelText,
        cancelColor: cancelColor,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(false),
          child: Text(cancelText ?? "Cancel"),
          style: TextButton.styleFrom(primary: cancelColor),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(true),
          child: Text(confirmText ?? "Confirm"),
          style: TextButton.styleFrom(primary: confirmColor),
        )
      ],
    );
  }
}
