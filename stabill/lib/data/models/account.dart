class Account {
  final String id;
  final String name;
  final int currentBalance;
  final int availableBalance;
  final DateTime createdAt;
  final bool archived;

  Account({
    required this.id,
    required this.name,
    required this.currentBalance,
    required this.availableBalance,
    required this.createdAt,
    required this.archived,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      currentBalance: json['current_balance'] as int,
      availableBalance: json['available_balance'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      archived: json['archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'current_balance': currentBalance,
      'available_balance': availableBalance,
      'created_at': createdAt.toIso8601String(),
      'archived': archived,
    };
  }
}
