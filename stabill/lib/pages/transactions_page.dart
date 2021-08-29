import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/widgets/transaction_modal.dart';

class TransactionArguments {
  final String accountID;
  final Account account;
  TransactionArguments(this.accountID, this.account);
}

class TransactionsPage extends StatefulWidget {
  static final String routeName = "/transactions";
  final String accountID;
  final Account account;

  const TransactionsPage(
      {Key? key, required this.accountID, required this.account})
      : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
      ),
      body: Center(
        child: Text(widget.accountID),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newTransaction = await Navigator.of(context).push(
            MaterialPageRoute<Transaction>(
              builder: (BuildContext context) => TransactionModal(),
              fullscreenDialog: true,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
