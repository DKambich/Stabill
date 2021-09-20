import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';

class BalanceCorrectionModal extends StatefulWidget {
  final String accountID;

  const BalanceCorrectionModal({
    Key? key,
    required this.accountID,
  }) : super(key: key);

  @override
  _BalanceCorrectionModalState createState() => _BalanceCorrectionModalState();

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
      builder: (_) => BalanceCorrectionModal(accountID: accountID),
    );
  }
}

class _BalanceCorrectionModalState extends State<BalanceCorrectionModal> {
  late DocumentReference<Account> _accountDocument;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _balanceController =
      TextEditingController(text: r"$0.00");

  String? errorText;

  @override
  void initState() {
    _accountDocument =
        context.read<DataProvider>().getAccountDocument(widget.accountID);

    _balanceController.addListener(() {
      String dollarStr = Account.formatDollarStr(_balanceController.text);
      if ((_balanceController.text.endsWith("-") ||
              _balanceController.text.startsWith("-")) &&
          _balanceController.text != r"$0.00-") {
        dollarStr = "-" + dollarStr;
      }

      if (_balanceController.text == r"-$0.00") {
        dollarStr = r"$0.00";
      }

      _balanceController.value = _balanceController.value.copyWith(
        text: dollarStr,
        selection: TextSelection(
          baseOffset: dollarStr.length,
          extentOffset: dollarStr.length,
        ),
        composing: TextRange.empty,
      );
    });
    super.initState();
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Balance Correction",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Enter the new balance for this account. This will mark all transactions as cleared and set the account balance to the sepecified value",
              ),
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: "New Balance",
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                enableInteractiveSelection: false,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (_) {
                  return errorText;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      child: Text("Confirm"),
                      onPressed: () async {
                        String newBalanceStr = _balanceController.text
                            .replaceAll(r"$", "")
                            .replaceAll(".", "");
                        int newBalance = int.parse(newBalanceStr);
                        int oldBalance = (await _accountDocument.get())
                            .data()!
                            .currentBalance;
                        if (newBalance != oldBalance) {
                          await context
                              .read<DataProvider>()
                              .updateBalance(widget.accountID, newBalance);
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            errorText = "New balance cannot equal old balance";
                            _formKey.currentState!.validate();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
