import 'package:stabill/data/models/transaction.dart';

enum ChangeType { insert, update, delete }

class TransactionChange {
  final ChangeType type;
  final Transaction transaction;

  TransactionChange({
    required this.type,
    required this.transaction,
  });
}
