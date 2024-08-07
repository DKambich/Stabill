import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  theme,
  prioritizePending,
  hideCleared,
  accountOrder,
  autocompleteHistoryLimit
}

class PreferenceProvider extends ChangeNotifier {
  SharedPreferences? _preferences;

  // Preference Properties
  late ThemeMode themePreference;
  late bool pendingPreference;
  late bool hideClearedPreference;
  late List<String> accountOrderPreference;
  late int autocompleteHistoryLimitPreference;

  PreferenceProvider() {
    themePreference = ThemeMode.light;
    pendingPreference = false;
    hideClearedPreference = false;
    accountOrderPreference = [];
    autocompleteHistoryLimitPreference = 50;
    _loadFromPrefs();
  }
  List<String> get accountOrder => accountOrderPreference;
  int get autocompleteHistoryLimit => autocompleteHistoryLimitPreference;
  bool get hideCleared => hideClearedPreference;
  bool get prioritizePending => pendingPreference;

  // Preference Getters
  ThemeMode get themeMode => themePreference;

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
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      primaryColor: Colors.green,
      brightness: brightness,
      checkboxTheme: CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.red;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.red;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.red;
          }
          return null;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.red;
          }
          return null;
        }),
      ),
    );
    return theme.copyWith(
      useMaterial3: false,
      colorScheme: theme.colorScheme.copyWith(
        primary: Colors.green,
        secondary: Colors.red,
        onSecondary: Colors.white,
      ),
    );
  }

  void setAccountOrder(List<String> accountOrder) {
    accountOrderPreference = accountOrder;
    _initPrefs().then(
      (value) => _preferences!
          .setStringList(PreferenceKey.accountOrder.name, accountOrder),
    );
    notifyListeners();
  }

  void setAutocompleteHistoryLimit(int historyLimit) {
    autocompleteHistoryLimitPreference = historyLimit;
    _initPrefs().then(
      (value) => _preferences!
          .setInt(PreferenceKey.autocompleteHistoryLimit.name, historyLimit),
    );
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void setHideCleared(bool hideCleared) {
    hideClearedPreference = hideCleared;
    _initPrefs().then(
      (value) =>
          _preferences!.setBool(PreferenceKey.hideCleared.name, hideCleared),
    );
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void setPrioritizePending(bool prioritizePending) {
    pendingPreference = prioritizePending;
    _initPrefs().then(
      (value) => _preferences!
          .setBool(PreferenceKey.prioritizePending.name, prioritizePending),
    );
    notifyListeners();
  }

  void setThemeMode(ThemeMode newMode) {
    themePreference = newMode;
    _initPrefs().then(
      (value) => _preferences!.setString(
        PreferenceKey.theme.name,
        themePreference.toString(),
      ),
    );
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadFromPrefs() async {
    await _initPrefs();
    final String theme = _preferences!.getString(PreferenceKey.theme.name) ??
        ThemeMode.light.toString();
    themePreference = ThemeMode.values.firstWhere(
      (type) => type.toString() == theme,
      orElse: () => ThemeMode.light,
    );
    pendingPreference =
        _preferences!.getBool(PreferenceKey.prioritizePending.name) ?? false;
    hideClearedPreference =
        _preferences!.getBool(PreferenceKey.hideCleared.name) ?? false;
    accountOrderPreference =
        _preferences!.getStringList(PreferenceKey.accountOrder.name) ?? [];
    autocompleteHistoryLimitPreference =
        _preferences!.getInt(PreferenceKey.autocompleteHistoryLimit.name) ?? 50;

    notifyListeners();
  }
}
