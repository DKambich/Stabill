class Transaction {
  String name;
  int amount;
  DateTime timestamp;
  int checkNumber;
  bool cleared, hidden;
  String memo;
  TransactionType method;

  Transaction({
    this.name = "",
    this.memo = "",
    this.amount = 0,
    this.checkNumber = -1,
    this.cleared = false,
    this.hidden = false,
    this.method = TransactionType.Withdrawal,
    required this.timestamp,
  });

  Transaction.fromJson(Map<String, dynamic> json)
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
