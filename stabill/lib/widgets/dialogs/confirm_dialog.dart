import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;
  final Color? cancelColor;

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
    String? confirmText,
    Color? confirmColor,
    String? cancelText,
    Color? cancelColor,
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
          style: TextButton.styleFrom(primary: cancelColor),
          child: Text(cancelText ?? "Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop<bool>(true),
          style: TextButton.styleFrom(primary: confirmColor),
          child: Text(confirmText ?? "Confirm"),
        )
      ],
    );
  }
}
