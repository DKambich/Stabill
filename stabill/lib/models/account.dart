class Account {
  String name;
  int availableBalance;
  int currentBalance;

  Account({this.name = "", this.availableBalance = 0, this.currentBalance = 0});

  Account.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name']! as String,
          availableBalance: json['availableBalance'].toInt(),
          currentBalance: json['currentBalance'].toInt(),
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'availableBalance': availableBalance,
      'currentBalance': currentBalance,
    };
  }

  static String formatDollarStr(String input) {
    // Remove all non-numeric characters
    String text = input.replaceAll(RegExp(r"[^\d]"), "");

    // Pad front of text with 0 until it is 3 characters
    if (text.length < 3) {
      text = text.padLeft(3, "0");
    }

    // Remove a zero from the front of the text if the length is 4
    if (text.startsWith("0") && text.length == 4) {
      text = text.substring(1);
    }

    // Insert the dollar sign
    text = "\$" + text;

    // Insert the decimal point
    text = text.substring(0, text.length - 2) +
        "." +
        text.substring(text.length - 2);

    return text;
  }
}
