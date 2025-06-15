/// Represents the balance for an account.
class Balance {
  /// The current balance in cents (includes all transactions).
  final int current;

  /// The available balance in cents (only cleared transactions).
  final int available;

  Balance({
    required this.current,
    required this.available,
  });

  /// Returns the available balance as a dollar amount.
  double get availableInDollars => available / 100.0;

  /// Returns the current balance as a dollar amount.
  double get currentInDollars => current / 100.0;

  @override
  String toString() {
    return 'Balance(current: \$${currentInDollars.toStringAsFixed(2)}, available: \$${availableInDollars.toStringAsFixed(2)})';
  }
}
