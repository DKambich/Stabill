import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String name;
  double amount;
  DateTime timestamp;
  int checkNumber;
  bool cleared;
  String memo;
  TransactionType method;

  Transaction({
    this.name = "",
    this.memo = "",
    this.amount = 0,
    this.checkNumber = -1,
    this.cleared = false,
    this.method = TransactionType.Withdrawal,
    required this.timestamp,
  });

  Transaction.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name'],
          memo: json['memo'],
          amount: json['amount'].toDouble(),
          checkNumber: json['checkNumber'],
          cleared: json['cleared'],
          method: TransactionType.values
              .firstWhere((element) => element.toString() == json['method']),
          timestamp: json['timestamp'].toDate(),
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'memo': memo,
      'amount': amount,
      'checkNumber': checkNumber,
      'cleared': cleared,
      'method': method.toString(),
      'timestamp': timestamp,
    };
  }
}

enum TransactionType {
  Withdrawal,
  Deposit,
}
