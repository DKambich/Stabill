import 'package:stabill/models/transaction.dart';

class ScheduledTransaction {
  final bool enabled;
  final bool hideIfCleared;
  final bool showNotifications;
  final String id;
  final String uid;
  final String accountID;
  final Frequency frequency;
  final Transaction transaction;

  ScheduledTransaction(
    this.transaction, {
    this.enabled = false,
    this.hideIfCleared = false,
    this.showNotifications = false,
    this.id = "",
    this.uid = "",
    this.accountID = "",
    this.frequency = Frequency.once,
  });

  ScheduledTransaction.fromJson(
    Map<String, dynamic> json,
    String id,
    String accountID,
  ) : this(
          Transaction.fromJson(json, ""),
          enabled: json['enabled'] as bool,
          hideIfCleared: json['hideIfCleared'] as bool,
          showNotifications: json['showNotifications'] as bool,
          id: id,
          uid: json['uid'] as String,
          accountID: accountID,
          frequency:
              FrequencyFormat.parseFrequency(json['frequency'] as String),
        );

  Map<String, Object?> toJson() {
    final Map<String, Object?> json = transaction.toJson();
    json['enabled'] = enabled;
    json['hideIfCleared'] = hideIfCleared;
    json['showNotifications'] = showNotifications;
    json['uid'] = uid;
    json['frequency'] = frequency.toString();
    return json;
  }
}

enum Frequency { once, daily, weekly, biweekly, endOfMonth, monthly, yearly }

extension FrequencyFormat on Frequency {
  static Frequency parseFrequency(String str) {
    return Frequency.values.firstWhere(
      (value) => value.toString().toLowerCase() == str.toLowerCase(),
      orElse: () => Frequency.once,
    );
  }

  String toFormattedString() {
    switch (this) {
      case Frequency.once:
        return "Once";
      case Frequency.daily:
        return "Daily";
      case Frequency.weekly:
        return "Weekly";
      case Frequency.biweekly:
        return "Every other Week";
      case Frequency.endOfMonth:
        return "End of the Month";
      case Frequency.monthly:
        return "Monthly";
      case Frequency.yearly:
        return "Yearly";
    }
  }
}
