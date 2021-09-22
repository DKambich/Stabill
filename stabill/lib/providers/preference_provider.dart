import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceProvider extends ChangeNotifier {
  final String key = "theme";
  late ThemeType mode;
  SharedPreferences? _preferences;

  ThemeType get themeMode => mode;

  PreferenceProvider() {
    mode = ThemeType.Light;
    _loadFromPrefs();
  }

  void setThemeMode(ThemeType newMode) {
    mode = newMode;
    _saveToPrefs();
    notifyListeners();
  }

  ThemeData getTheme(BuildContext context, ThemeType mode) {
    final brightness;
    switch (mode) {
      case ThemeType.Light:
        brightness = Brightness.light;
        break;
      case ThemeType.Dark:
        brightness = Brightness.dark;
        break;
      case ThemeType.System:
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

  _initPrefs() async {
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    String theme = _preferences!.getString(key) ?? ThemeType.Light.toString();
    mode = ThemeType.values.firstWhere((type) => type.toString() == theme);
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _preferences!.setString(key, mode.toString());
  }
}

enum ThemeType { Light, Dark, System }
