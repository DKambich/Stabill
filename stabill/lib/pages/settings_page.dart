import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/widgets/dialogs/theme_picker.dart';

class SettingsPage extends StatefulWidget {
  static final String routeName = "/settings";

  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    ThemeType mode = context.watch<PreferenceProvider>().themeMode;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(mode == ThemeType.Light
                ? Icons.light_mode
                : mode == ThemeType.Dark
                    ? Icons.dark_mode
                    : Icons.brightness_auto),
            title: Text("Toggle theme"),
            onTap: () async => context.read<PreferenceProvider>().setThemeMode(
                  await ThemePicker.show(
                    context,
                    mode,
                  ),
                ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Sign out"),
            onTap: () async {
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginPage.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
