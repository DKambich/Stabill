import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';

class EditAccountModal extends StatefulWidget {
  final String accountID;

  const EditAccountModal({Key? key, required this.accountID}) : super(key: key);

  @override
  _EditAccountModalState createState() => _EditAccountModalState();

  static void show(BuildContext context, String accountID) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (_) => EditAccountModal(accountID: accountID),
    );
  }
}

class _EditAccountModalState extends State<EditAccountModal> {
  final TextEditingController _accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              Text(
                "Edit Account",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  autofocus: true,
                  controller: _accountController,
                  decoration: InputDecoration(
                    labelText: "New Account Name",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Update the account
                              DataProvider dataProvider =
                                  context.read<DataProvider>();
                              Account account = await dataProvider
                                  .getAccount(widget.accountID);
                              account.name = _accountController.text;
                              await dataProvider.updateAccount(account);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Confirm')),
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
    super.dispose();
  }
}
