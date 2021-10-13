import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/pages/scheduled_transactions_page.dart';
import 'package:stabill/pages/settings_page.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/widgets/account_list.dart';
import 'package:stabill/widgets/modals/create_account_modal.dart';
import 'package:stabill/widgets/modals/transfer_funds_modal.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/home";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum HomePageAction { export, import, settings }

class _HomePageState extends State<HomePage> {
  int index = 0;
  PageController controller = PageController();
  bool hideFAB = false;

  void shouldHideFAB({bool hide = false}) {
    if (hide != hideFAB) {
      setState(() {
        hideFAB = hide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Stabill"),
        actions: [
          PopupMenuButton(
            shape: menuShape,
            onSelected: (HomePageAction selected) async {
              switch (selected) {
                case HomePageAction.import:
                  try {
                    final FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
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
                  break;
                case HomePageAction.export:
                  break;
                case HomePageAction.settings:
                  Navigator.of(context).pushNamed(SettingsPage.routeName);
                  break;
              }
            },
            itemBuilder: (ctx) {
              return <PopupMenuEntry<HomePageAction>>[
                const PopupMenuItem<HomePageAction>(
                  value: HomePageAction.import,
                  child: ListTile(
                    leading: Icon(Icons.file_download_outlined),
                    title: Text("Import Data"),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem<HomePageAction>(
                  value: HomePageAction.export,
                  child: ListTile(
                    leading: Icon(Icons.file_upload_outlined),
                    title: Text("Export Data"),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem<HomePageAction>(
                  value: HomePageAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: PageView(
        controller: controller,
        children: [
          AccountList(
            shouldHideFAB: (bool hide) => shouldHideFAB(hide: hide),
          ),
          const Center(child: Text("Insights"))
        ],
        onPageChanged: (int index) {
          setState(() {
            this.index = index;
          });
        },
      ),
      floatingActionButton: index == 0 && !hideFAB
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              tooltip: 'Actions',
              spacing: 8,
              spaceBetweenChildren: 8,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.savings),
                  label: "Add Account",
                  onTap: () => CreateAccountModal.show(context),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.swap_horiz),
                  label: "Make Transfer",
                  onTap: () => TransferFundsModal.show(context),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.schedule_outlined),
                  label: "Schedule Transactions",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ScheduledTransactionsPage.routeName,
                    );
                  },
                ),
              ],
              child: const Icon(Icons.account_balance),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
        ],
        currentIndex: index,
        onTap: (int index) {
          setState(
            () {
              this.index = index;
              controller.jumpToPage(index);
            },
          );
        },
      ),
    );
  }
}
