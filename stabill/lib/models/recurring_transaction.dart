import 'package:stabill/models/transaction.dart';

class RecurringTransaction {
  final bool enabled;
  final bool hideIfCleared;
  final Frequency frequency;
  final Transaction transaction;

  RecurringTransaction(
    this.transaction, {
    this.enabled = false,
    this.hideIfCleared = false,
    this.frequency = Frequency.once,
  });

  RecurringTransaction.fromJson(Map<String, dynamic> json)
      : this(
          Transaction.fromJson(json, ""),
          enabled: json['enabled'] as bool,
          hideIfCleared: json['hideIfCleared'] as bool,
          frequency: Frequency.values.firstWhere(
            (value) =>
                value.toString().toLowerCase() ==
                (json['frequency']! as String).toLowerCase(),
          ),
        );

  Map<String, Object?> toJson() {
    final Map<String, Object?> json = transaction.toJson();
    json['enabled'] = enabled;
    json['hideIfCleared'] = hideIfCleared;
    json['frequency'] = frequency.toString();
    return json;
  }
}

enum Frequency { once, daily, weekly, biweekly, endOfMonth, monthly, yearly }
