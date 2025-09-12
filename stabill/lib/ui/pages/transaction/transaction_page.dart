import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  final String accountId;
  final String? transactionId;
  const TransactionPage(
      {super.key, required this.accountId, this.transactionId});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            'Transaction Page for Account ID: ${widget.accountId}, Transaction ID: ${widget.transactionId ?? "New Transaction"}'),
      ),
    );
  }
}
