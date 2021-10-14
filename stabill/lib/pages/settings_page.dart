import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/widgets/dialogs/theme_picker.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = "/settings";

  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool val = false;

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = context.watch<PreferenceProvider>().themeMode;
    final Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  brightness == Brightness.light
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
              ],
            ),
            title: const Text("Theme"),
            subtitle: const Text(
              "Set the theme used in the app",
            ),
            onTap: () async => context.read<PreferenceProvider>().setThemeMode(
                  await ThemePicker.show(
                    context,
                    mode,
                  ),
                ),
          ),
          SwitchListTile(
            secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  val
                      ? Icons.notifications_rounded
                      : Icons.notifications_off_rounded,
                ),
              ],
            ),
            title: const Text("Notifications"),
            subtitle: const Text(
              "Recieve notifications when scheduled transactions process",
            ),
            value: val,
            onChanged: (value) {
              setState(() {
                val = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.logout_rounded)],
            ),
            title: const Text("Sign out"),
            subtitle: const Text("Sign out of your account on this device"),
            onTap: () async {
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginPage.routeName,
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.delete_forever_rounded)],
            ),
            title: const Text("Delete Account"),
            subtitle: const Text("Delete your account and any associated data"),
            onTap: () async {
              // Show delete account dialog
            },
          ),
        ],
      ),
    );
  }
}
