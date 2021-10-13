class Account {
  String name;
  String id;
  int availableBalance;
  int currentBalance;

  Account({
    this.name = "",
    this.id = "",
    this.availableBalance = 0,
    this.currentBalance = 0,
  });

  Account.fromJson(Map<String, dynamic> json, String id)
      : this(
          name: json['name']! as String,
          availableBalance: (json['availableBalance']! as num).toInt(),
          currentBalance: (json['currentBalance']! as num).toInt(),
          id: id,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'availableBalance': availableBalance,
      'currentBalance': currentBalance,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is Account && other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      availableBalance.hashCode ^
      currentBalance.hashCode;
}
