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
}

enum TransactionType {
  Withdrawal,
  Deposit,
}
