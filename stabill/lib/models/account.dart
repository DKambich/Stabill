class Account {
  String name;
  double availableBalance;
  double currentBalance;

  Account({this.name = "", this.availableBalance = 0, this.currentBalance = 0});

  Account.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name']! as String,
          availableBalance: json['availableBalance'].toDouble(),
          currentBalance: json['currentBalance'].toDouble(),
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'availableBalance': availableBalance,
      'currentBalance': currentBalance,
    };
  }
}
