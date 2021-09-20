import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/providers/preference_provider.dart';

class SettingsPage extends StatefulWidget {
  static final String routeName = "/settings";

  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = context.watch<PreferenceProvider>().darkTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(darkTheme ? Icons.dark_mode : Icons.light_mode),
            title: Text("Toggle theme"),
            onTap: context.read<PreferenceProvider>().toggleTheme,
            trailing: Switch(
              value: darkTheme,
              onChanged: (boo) {
                context.read<PreferenceProvider>().toggleTheme();
              },
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
