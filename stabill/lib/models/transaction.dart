import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String name;
  String memo;
  String id;
  int amount;
  int checkNumber;
  DateTime timestamp;
  bool cleared;
  bool hidden;
  TransactionType method;

  Transaction({
    this.name = "",
    this.memo = "",
    this.id = "",
    this.amount = 0,
    this.checkNumber = -1,
    this.cleared = false,
    this.hidden = false,
    this.method = TransactionType.withdrawal,
    required this.timestamp,
  });

  Transaction.fromJson(Map<String, dynamic> json, String id)
      : this(
          name: json['name']! as String,
          memo: json['memo']! as String,
          amount: (json['amount']! as num).toInt(),
          checkNumber: (json['checkNumber']! as num).toInt(),
          cleared: json['cleared'] as bool,
          hidden: json['hidden'] as bool,
          method: TransactionType.values
              .firstWhere((element) => element.toString() == json['method']),
          timestamp: (json['timestamp']! as Timestamp).toDate(),
          id: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'memo': memo,
      'amount': amount,
      'checkNumber': checkNumber,
      'cleared': cleared,
      'hidden': hidden,
      'method': method.toString(),
      'timestamp': timestamp,
    };
  }
}

enum TransactionType {
  withdrawal,
  deposit,
}
