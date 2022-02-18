import 'package:flutter/material.dart';
import 'package:stabill/constants.dart';

class Prompt extends StatelessWidget {
  final String title;
  final Widget formBody;
  final void Function() onConfirm;
  final void Function() onCancel;

  const Prompt({
    Key? key,
    required this.formBody,
    required this.title,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 24,
        ).copyWith(bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            formBody,
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: onConfirm,
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, Widget prompt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: dialogShape,
        contentPadding: EdgeInsets.zero,
        content: prompt,
      ),
    );
  }
}
