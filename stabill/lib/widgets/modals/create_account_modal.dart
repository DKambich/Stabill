import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/dollar_formatter.dart';

class CreateAccountModal extends StatefulWidget {
  const CreateAccountModal({Key? key}) : super(key: key);
  @override
  _CreateAccountModalState createState() => _CreateAccountModalState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (_) => const CreateAccountModal(),
    );
  }
}

class _CreateAccountModalState extends State<CreateAccountModal> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _balanceController =
      TextEditingController(text: r"$0.00");
  final _formKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  //   _balanceController.addListener(() {
  //     String dollarStr = Account.formatDollarStr(_balanceController.text);

  //     _balanceController.value = _balanceController.value.copyWith(
  //       text: dollarStr,
  //       selection: TextSelection(
  //         baseOffset: dollarStr.length,
  //         extentOffset: dollarStr.length,
  //       ),
  //       composing: TextRange.empty,
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 48.0,
          right: 48.0,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  autofocus: true,
                  controller: _accountController,
                  decoration: const InputDecoration(
                    labelText: "Account Name",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Account name too short';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Starting Balance",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  enableInteractiveSelection: false,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [DollarTextInputFormatter(maxDigits: 8)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Setup the new account
                            final Account account = Account(
                              name: _accountController.text,
                            );

                            final int startingBalance = int.parse(
                              _balanceController.text
                                  .replaceAll(RegExp(r"[^\d]"), ""),
                            );

                            await context.read<DataProvider>().createAccount(
                                  account,
                                  startingBalance,
                                );
                            // Create the new Account
                            // await createAccount(newAccount, accountBalance);
                            if (!mounted) return;
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
