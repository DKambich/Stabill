class Account {
  String name;
  double availableBalance;
  double currentBalance;

  Account({this.name = "", this.availableBalance = 0, this.currentBalance = 0});

  Account.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          availableBalance: json['availableBalance']! as double,
          currentBalance: json['currentBalance']! as double,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'availableBalance': availableBalance,
      'currentBalance': currentBalance,
    };
  }
}
