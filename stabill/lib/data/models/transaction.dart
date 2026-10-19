import 'package:stabill/data/enums/transaction_category.dart';
import 'package:stabill/data/enums/transaction_type.dart';
import 'package:stabill/data/tables/transactions_table.dart';

/// Represents a single financial transaction within an account.

class Transaction {
  /// Unique identifier for the transaction.
  final String? id;

  /// The account that owns this transaction.
  final String? accountId;

  /// The timestamp when the transaction was created.
  final DateTime? createdAt;

  /// The description or name of the transaction.
  final String name;

  /// The non-negative transaction amount in cents; transactionType determines direction.
  final int amount;

  /// The date when the transaction occurred.
  final DateTime transactionDate;

  /// The type of transaction.
  final TransactionType transactionType;

  /// The high-level category for the transaction.
  final TransactionCategory category;

  /// The check number associated with the transaction (if applicable).
  final int? checkNumber;

  /// Additional notes or memo about the transaction.
  final String? memo;

  /// Indicates whether the transaction has cleared.
  final bool isCleared;

  /// Indicates whether the transaction has been archived.
  final bool isArchived;

  Transaction({
    this.id,
    this.accountId,
    required this.name,
    this.createdAt,
    required this.amount,
    required this.transactionDate,
    required this.transactionType,
    required this.category,
    this.checkNumber,
    this.memo,
    required this.isCleared,
    required this.isArchived,
  });

  /// Creates a [Transaction] instance from a JSON object.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json[TransactionsTable.id] as String,
      accountId: json[TransactionsTable.accountId] as String?,
      name: json[TransactionsTable.name] as String,
      createdAt: DateTime.parse(json[TransactionsTable.createdAt] as String),
      amount: json[TransactionsTable.amount] as int,
      transactionDate:
          DateTime.parse(json[TransactionsTable.transactionDate] as String),
      transactionType: TransactionType.fromJson(
        json[TransactionsTable.transactionType] as String,
      ),
      category: TransactionCategory.fromJson(
        json[TransactionsTable.transactionCategory] as String,
      ),
      checkNumber: json[TransactionsTable.checkNumber] as int?,
      memo: json[TransactionsTable.memo] as String?,
      isCleared: json[TransactionsTable.isCleared] as bool,
      isArchived: json[TransactionsTable.isArchived] as bool,
    );
  }

  Transaction copyWith({
    String? id,
    String? accountId,
    DateTime? createdAt,
    String? name,
    int? amount,
    DateTime? transactionDate,
    TransactionType? transactionType,
    TransactionCategory? category,
    int? checkNumber,
    String? memo,
    bool? isCleared,
    bool? isArchived,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionType: transactionType ?? this.transactionType,
      category: category ?? this.category,
      checkNumber: checkNumber ?? this.checkNumber,
      memo: memo ?? this.memo,
      isCleared: isCleared ?? this.isCleared,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Converts the [Transaction] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      TransactionsTable.id: id,
      TransactionsTable.accountId: accountId,
      TransactionsTable.name: name,
      TransactionsTable.createdAt: createdAt?.toIso8601String(),
      TransactionsTable.amount: amount,
      TransactionsTable.transactionDate: transactionDate.toIso8601String(),
      TransactionsTable.transactionType: transactionType.toJson(),
      TransactionsTable.transactionCategory: category.toJson(),
      TransactionsTable.checkNumber: checkNumber,
      TransactionsTable.memo: memo,
      TransactionsTable.isCleared: isCleared,
      TransactionsTable.isArchived: isArchived,
    };
  }

  /// Returns a string representation of the [Transaction] instance.
  @override
  String toString() {
    return 'Transaction(id: $id, name: $name, amount: $amount, '
        'transactionType: $transactionType, category: $category, '
        'transactionDate: ${transactionDate.toIso8601String()}, '
        'cleared: $isCleared, archived: $isArchived)';
  }
}
