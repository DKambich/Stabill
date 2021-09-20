import 'package:flutter/cupertino.dart';

class PreferenceProvider extends ChangeNotifier {
  final String key = "theme";
  late bool _darkTheme;
  bool get darkTheme => _darkTheme;
  PreferenceProvider() {
    _darkTheme = true;
  }
  toggleTheme() {
    _darkTheme = !_darkTheme;
    notifyListeners();
  }
}
