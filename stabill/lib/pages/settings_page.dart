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
    ThemeMode mode = context.watch<PreferenceProvider>().themeMode;
    Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(
              brightness == Brightness.light
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
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
