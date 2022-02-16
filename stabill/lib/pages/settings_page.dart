import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';
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
            onTap: () => themeSetting(mode),
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
            onChanged: notificationSetting,
          ),
          const Divider(),
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.file_download_rounded)],
            ),
            title: const Text("Import Data"),
            subtitle: const Text("Import data into your account"),
            onTap: importData,
          ),
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.file_upload_rounded)],
            ),
            title: const Text("Export Data"),
            subtitle: const Text("Export data out of your account"),
            onTap: exportData,
          ),
          const Divider(),
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.logout_rounded)],
            ),
            title: const Text("Sign out"),
            subtitle: const Text("Sign out of your account on this device"),
            onTap: showLogoutAccount,
          ),
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.delete_forever_rounded)],
            ),
            title: const Text("Delete Account"),
            subtitle: const Text("Delete your account and any associated data"),
            onTap: showDeleteAccount,
          ),
        ],
      ),
    );
  }

  Future<void> themeSetting(ThemeMode currentMode) async {
    final PreferenceProvider preferenceProvider =
        context.read<PreferenceProvider>();
    final ThemeMode newMode = await ThemePicker.show(context, currentMode);
    preferenceProvider.setThemeMode(newMode);
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> notificationSetting(bool showNotifications) async {
    setState(() {
      val = showNotifications;
    });
  }

  Future<void> importData() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      if (result != null) {
        final File csv = File(result.files[0].path!);
        if (!mounted) return;
        await context.read<DataProvider>().importCSV(csv);
      }
    } catch (e) {
      // TODO: Show there is an error
    }
  }

  Future<void> exportData() async {}

  Future<void> showLogoutAccount() async {
    final bool shouldLogout = await ConfirmDialog.show(
      context,
      "Logout?",
      "Are you sure you want to logout from your account?",
      confirmText: const Text(
        "Confirm",
        style: TextStyle(color: Colors.red),
      ),
    );
    if (mounted && shouldLogout) {
      context.read<AuthProvider>().signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginPage.routeName,
        (route) => false,
      );
    }
  }

  Future<void> showDeleteAccount() async {
    final bool shouldDelete = await ConfirmDialog.show(
      context,
      "Delete Account?",
      "Are you sure you want to delete your account and all associated data?",
      confirmText: const Text(
        "Confirm",
        style: TextStyle(color: Colors.red),
      ),
    );
    if (mounted && shouldDelete) {
      // Delete the account
    }
  }
}
