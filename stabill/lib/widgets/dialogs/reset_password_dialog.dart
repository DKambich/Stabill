import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/providers/auth_provider.dart';

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (_) => const ResetPasswordDialog(),
    );
  }

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (await context
              .read<AuthProvider>()
              .resetPassword(emailController.text) ==
          false) {
        showToast("Failed to reset password, try again");
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reset Password"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your email to receive a link to reset your password",
            ),
            dialogFieldSpace,
            TextFormField(
              autofocus: true,
              controller: emailController,
              decoration: textInputDecoration(
                prefixIcon: Icons.email,
                hintText: "Email",
              ),
              style: const TextStyle(color: Colors.grey),
              validator: emailValidator,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      shape: dialogShape,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => resetPassword(),
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
