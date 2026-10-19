import 'package:stabill/data/models/transaction.dart';

enum ChangeType { insert, update, delete }

class TransactionChange {
  final ChangeType type;
  final Transaction? transaction;
  final String? transactionId;

  TransactionChange({
    required this.type,
    this.transaction,
    this.transactionId,
  }) : assert(transaction != null || transactionId != null);
}
