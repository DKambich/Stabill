// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/reorder_accounts_page.dart';
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
  bool showNotifications = false;

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = context.watch<PreferenceProvider>().themeMode;
    final Brightness brightness = Theme.of(context).brightness;
    final bool prioritizePending =
        context.watch<PreferenceProvider>().prioritizePending;
    final bool hideCleared = context.watch<PreferenceProvider>().hideCleared;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionHeader("Display"),
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
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Icon(Icons.format_list_numbered_rounded)],
              ),
              title: const Text("Reorder Accounts"),
              subtitle: const Text(
                "Change the order in which accounts are displayed",
              ),
              onTap: () => Navigator.of(context).pushNamed(
                ReorderAccountsPage.routeName,
              ),
            ),
            SwitchListTile(
              secondary: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showNotifications
                        ? Icons.notifications_rounded
                        : Icons.notifications_off_rounded,
                  ),
                ],
              ),
              title: const Text("Notifications"),
              subtitle: const Text(
                "Recieve notifications when scheduled transactions process",
              ),
              value: showNotifications,
              onChanged: notificationSetting,
            ),
            SwitchListTile(
              secondary: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Icon(Icons.pending_actions_rounded)],
              ),
              title: const Text("Prioritize Pending Transactions"),
              subtitle: const Text(
                "Show pending transactions before cleared transactions",
              ),
              value: prioritizePending,
              onChanged: pendingTransactionSetting,
            ),
            SwitchListTile(
              secondary: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hideCleared
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ],
              ),
              title: const Text("Hide Cleared Transactions"),
              subtitle: const Text(
                "Hide transactions that are cleared",
              ),
              value: hideCleared,
              onChanged: clearedTransactionSetting,
            ),
            const Divider(),
            sectionHeader("Data"),
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
              subtitle: const Text("Export data from your account"),
              onTap: exportData,
            ),
            const Divider(),
            sectionHeader("Account"),
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
              subtitle:
                  const Text("Delete your account and any associated data"),
              onTap: showDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 15),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      this.showNotifications = showNotifications;
    });
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> pendingTransactionSetting(bool prioritizePending) async {
    context.read<PreferenceProvider>().setPrioritizePending(prioritizePending);
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> clearedTransactionSetting(bool hideCleared) async {
    context.read<PreferenceProvider>().setHideCleared(hideCleared);
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

  Future<void> exportData() async {
    final String fileName =
        'StabillExport-${DateFormat("MM-dd-yyyy-kk-mm-ss").format(DateTime.now())}.csv';
    if (kIsWeb) {
      // Create the CSV from the Account data
      final String csv = await context.read<DataProvider>().exportCSV();
      // Create a Blob to download from the CSV data
      final csvBlob = html.Blob([csv], 'text/plain', 'native');
      // Create and click on the Anchor element to download the file
      final webAnchor =
          html.AnchorElement(href: html.Url.createObjectUrlFromBlob(csvBlob))
            ..setAttribute("download", fileName)
            ..click();
      //Remove the web anchor from the page
      webAnchor.remove();
    } else if (Platform.isAndroid) {
      // Store the path to the downloads folder
      const String exportPath = '/storage/emulated/0/Download/Stabill/Exports';
      // Check if the app has permission to export the file
      if (await Permission.storage.request().isGranted &&
          await Permission.manageExternalStorage.request().isGranted) {
        // Create a the file
        final File file = File('$exportPath/$fileName');
        file.createSync(recursive: true);
        // Create the CSV from the Account data and write it to the file
        final String csv = await context.read<DataProvider>().exportCSV();
        file.writeAsStringSync(csv);
      }
    }
    // TODO: Notify that the user of where the file was stored
  }

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
