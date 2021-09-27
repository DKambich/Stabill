import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceProvider extends ChangeNotifier {
  final String key = "theme";
  late ThemeMode mode;
  SharedPreferences? _preferences;

  ThemeMode get themeMode => mode;

  PreferenceProvider() {
    mode = ThemeMode.light;
    _loadFromPrefs();
  }

  void setThemeMode(ThemeMode newMode) {
    mode = newMode;
    _saveToPrefs();
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
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _initPrefs();
    _preferences!.setString(key, mode.toString());
  }
}
