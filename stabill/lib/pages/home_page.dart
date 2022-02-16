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
import 'package:stabill/widgets/prompts/create_account_prompt.dart';
import 'package:stabill/widgets/prompts/transfer_funds_prompt.dart';

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
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsPage.routeName),
          ),
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
                  child: const Icon(Icons.savings_rounded),
                  label: "Add Account",
                  onTap: () => CreateAccountPrompt.show(context),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.swap_horiz_rounded),
                  label: "Make Transfer",
                  onTap: () => TransferFundsPrompt.show(context),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.schedule_rounded),
                  label: "Schedule Transactions",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ScheduledTransactionsPage.routeName,
                    );
                  },
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_rounded),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
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
