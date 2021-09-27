class Transaction {
  String name, memo, id;
  int amount, checkNumber;
  DateTime timestamp;
  bool cleared, hidden;
  TransactionType method;

  Transaction({
    this.name = "",
    this.memo = "",
    this.id = "",
    this.amount = 0,
    this.checkNumber = -1,
    this.cleared = false,
    this.hidden = false,
    this.method = TransactionType.Withdrawal,
    required this.timestamp,
  });

  Transaction.fromJson(Map<String, dynamic> json, String id)
      : this(
          name: json['name'],
          memo: json['memo'],
          amount: json['amount'].toInt(),
          checkNumber: json['checkNumber'],
          cleared: json['cleared'],
          hidden: json['hidden'],
          method: TransactionType.values
              .firstWhere((element) => element.toString() == json['method']),
          timestamp: json['timestamp'].toDate(),
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
  Withdrawal,
  Deposit,
}
