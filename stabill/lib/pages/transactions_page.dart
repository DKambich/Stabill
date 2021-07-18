import 'package:flutter/material.dart';

class TransactionArguments {
  final String accountID;
  TransactionArguments(this.accountID);
}

class TransactionsPage extends StatefulWidget {
  static final String routeName = "/transactions";
  final String accountID;

  const TransactionsPage({Key? key, required this.accountID}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountID),
      ),
      body: Center(
        child: Text(widget.accountID),
      ),
    );
  }
}
