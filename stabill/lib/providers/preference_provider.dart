import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceProvider extends ChangeNotifier {
  final String key = "theme";
  late ThemeMode mode;
  final String key2 = "prioritizePending";
  late bool pendingPreference;
  final String key3 = "hideCleared";
  late bool hideClearedPreference;
  final String key4 = "accountOrder";
  late List<String> accountOrderPreference;
  final String key5 = "autocompleteHistoryLimit";
  late int autocompleteHistoryLimit;
  SharedPreferences? _preferences;

  ThemeMode get themeMode => mode;
  bool get prioritizePending => pendingPreference;
  bool get hideCleared => hideClearedPreference;
  List<String> get accountOrder => accountOrderPreference;

  PreferenceProvider() {
    mode = ThemeMode.light;
    pendingPreference = false;
    hideClearedPreference = false;
    accountOrderPreference = [];
    autocompleteHistoryLimit = 50;
    _loadFromPrefs();
  }

  void setThemeMode(ThemeMode newMode) {
    mode = newMode;
    _initPrefs().then((value) => _preferences!.setString(key, mode.toString()));
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void setPrioritizePending(bool prioritizePending) {
    pendingPreference = prioritizePending;
    _initPrefs()
        .then((value) => _preferences!.setBool(key2, prioritizePending));
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void setHideCleared(bool hideCleared) {
    hideClearedPreference = hideCleared;
    _initPrefs().then((value) => _preferences!.setBool(key3, hideCleared));
    notifyListeners();
  }

  void setAccountOrder(List<String> accountOrder) {
    accountOrderPreference = accountOrder;
    _initPrefs()
        .then((value) => _preferences!.setStringList(key4, accountOrder));
    notifyListeners();
  }

  void setAutocompleteHistoryLimit(int historyLimit) {
    autocompleteHistoryLimit = historyLimit;
    _initPrefs().then((value) => _preferences!.setInt(key5, historyLimit));
    notifyListeners();
  }

  ThemeData getTheme(BuildContext context, ThemeMode mode) {
    final Brightness brightness;
    switch (mode) {
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      case ThemeMode.system:
        brightness = MediaQuery.of(context).platformBrightness;
        break;
      default:
        brightness = Brightness.light;
    }

    final theme = ThemeData(
      primaryColor: Colors.green,
      toggleableActiveColor: Colors.red,
      brightness: brightness,
    );
    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: Colors.green,
        secondary: Colors.red,
        onSecondary: Colors.white,
      ),
    );
  }

  Future<void> _initPrefs() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadFromPrefs() async {
    await _initPrefs();
    final String theme =
        _preferences!.getString(key) ?? ThemeMode.light.toString();
    mode = ThemeMode.values.firstWhere(
      (type) => type.toString() == theme,
      orElse: () => ThemeMode.light,
    );
    pendingPreference = _preferences!.getBool(key2) ?? false;
    hideClearedPreference = _preferences!.getBool(key3) ?? false;
    accountOrderPreference = _preferences!.getStringList(key4) ?? [];
    autocompleteHistoryLimit = _preferences!.getInt(key5) ?? 50;

    notifyListeners();
  }
}
