import 'package:flutter/material.dart';

// TODO: This is a sampling of the transaction categories we could support.
// We will flesh out the list but this is meant so we can have a control in the UI
enum TransactionCategory {
  none,
  income,
  housing,
  utilities,
  transportation,
  food,
  healthcare,
  entertainment,
  savingsInvestments,
  education,
  debtPayments,
  giftsDonations,
  travel,
  other;

  IconData get icon {
    switch (this) {
      case TransactionCategory.none:
        return Icons.help_outline;
      case TransactionCategory.income:
        return Icons.attach_money;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.lightbulb;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.healthcare:
        return Icons.local_hospital;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.savingsInvestments:
        return Icons.savings;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.debtPayments:
        return Icons.account_balance;
      case TransactionCategory.giftsDonations:
        return Icons.card_giftcard;
      case TransactionCategory.travel:
        return Icons.flight;
      case TransactionCategory.other:
        return Icons.category;
    }
  }

  String get label {
    switch (this) {
      case TransactionCategory.none:
        return 'Uncategorized';
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.housing:
        return 'Housing';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.transportation:
        return 'Transportation';
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.healthcare:
        return 'Healthcare';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.savingsInvestments:
        return 'Savings & Investments';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.debtPayments:
        return 'Debt Payments';
      case TransactionCategory.giftsDonations:
        return 'Gifts & Donations';
      case TransactionCategory.travel:
        return 'Travel';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  int get sortOrder {
    switch (this) {
      case TransactionCategory.none:
        return 0;
      case TransactionCategory.income:
        return 1;
      case TransactionCategory.housing:
        return 2;
      case TransactionCategory.utilities:
        return 3;
      case TransactionCategory.transportation:
        return 4;
      case TransactionCategory.food:
        return 5;
      case TransactionCategory.healthcare:
        return 6;
      case TransactionCategory.entertainment:
        return 7;
      case TransactionCategory.savingsInvestments:
        return 8;
      case TransactionCategory.education:
        return 9;
      case TransactionCategory.debtPayments:
        return 10;
      case TransactionCategory.giftsDonations:
        return 11;
      case TransactionCategory.travel:
        return 12;
      case TransactionCategory.other:
        return 13;
    }
  }

  /// Supabase string representation
  String toJson() => name;

  /// From Supabase string
  static TransactionCategory fromJson(String value) {
    return TransactionCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionCategory.none,
    );
  }
}
