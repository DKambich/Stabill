import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/providers/auth_provider.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({Key? key}) : super(key: key);

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();

  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool?>(
          context: context,
          builder: (_) => const DeleteAccountDialog(),
        ) ??
        false;
  }
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Account"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Verify your email and password to delete your account",
              ),
              dialogFieldSpace,
              TextFormField(
                autofocus: true,
                controller: emailController,
                decoration: textInputDecoration(
                  prefixIcon: Icons.email_rounded,
                  hintText: "Email",
                ),
                style: const TextStyle(color: Colors.grey),
                validator: emailValidator,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              dialogFieldSpace,
              TextFormField(
                controller: passwordController,
                decoration: textInputDecoration(
                  prefixIcon: Icons.lock_rounded,
                  hintText: "Password",
                ),
                style: const TextStyle(color: Colors.grey),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
      shape: dialogShape,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => deleteAccount(),
          child: const Text("Confirm"),
        ),
      ],
    );
  }

  Future<void> deleteAccount() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (await context
              .read<StabillAuthProvider>()
              .deleteAccount(emailController.text, passwordController.text) ==
          false) {
        showToast(
          "Failed to delete account, ensure you used the correct email and password and try again",
        );
        if (mounted) Navigator.of(context).pop(false);
      }
      if (mounted) Navigator.of(context).pop(true);
    }
  }
}
