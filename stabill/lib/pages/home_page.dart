import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/pages/settings_page.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/widgets/modals/create_account_modal.dart';
import 'package:stabill/widgets/account_list.dart';
import 'package:stabill/widgets/modals/transfer_funds_modal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stabill/models/transaction.dart' as Stabill;

class HomePage extends StatefulWidget {
  static final String routeName = "/home";

  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum HomePageAction { Export, Import, Settings }

class _HomePageState extends State<HomePage> {
  int index = 0;
  PageController controller = new PageController();
  bool hideFAB = false;

  void shouldHideFAB(bool hide) {
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
        title: Text("Stabill"),
        actions: [
          PopupMenuButton(onSelected: (HomePageAction selected) async {
            switch (selected) {
              case HomePageAction.Import:
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowedExtensions: ['csv'],
                  type: FileType.custom,
                  allowMultiple: false,
                );
                if (result != null) {
                  File file = File(result.files[0].path!);

                  final lines = await file.readAsLines();

                  List<String> headers = lines[0].split(",");
                  print(headers);
                  lines.removeAt(0);

                  Map<String, int> headerIndex = headers
                      .asMap()
                      .map<String, int>((key, value) => MapEntry(value, key));

                  Map<String, List<Stabill.Transaction>> accounts =
                      Map<String, List<Stabill.Transaction>>();

                  for (String line in lines) {
                    final entries = line.split(",");
                    Stabill.Transaction transaction = Stabill.Transaction(
                      name: entries[headerIndex["Transaction_Name"]!],
                      amount: int.parse(entries[headerIndex["Amount"]!]),
                      checkNumber: int.parse(entries[headerIndex["Check_No"]!]),
                      cleared:
                          entries[headerIndex["Has_Cleared"]!].toLowerCase() ==
                              "true",
                      method: entries[headerIndex["Transaction_Type"]!]
                                  .toLowerCase() ==
                              "true"
                          ? Stabill.TransactionType.Deposit
                          : Stabill.TransactionType.Withdrawal,
                      timestamp: DateTime.fromMillisecondsSinceEpoch(
                          int.parse(entries[headerIndex["Creation_Date"]!])),
                      hidden:
                          entries[headerIndex["Is_Hidden"]!].toLowerCase() ==
                              "true",
                      memo: entries[headerIndex["Memo"]!],
                    );

                    var list = accounts.putIfAbsent(
                      entries[headerIndex["Account_Name"]!],
                      () => [],
                    );
                    list.add(transaction);
                  }

                  // Initialize Firebase variables
                  DataProvider dataProvider = context.read<DataProvider>();
                  var _accountsCollection =
                      dataProvider.getAccountsCollection();

                  for (String key in accounts.keys) {
                    Account newAccount = Account(name: key);
                    var accountRef = await _accountsCollection.add(newAccount);
                    List<Stabill.Transaction> transactions = accounts[key]!;
                    List<List<Stabill.Transaction>> sublists = [];
                    for (int i = 0; i < transactions.length; i += 499) {
                      sublists.add(transactions.sublist(
                          i,
                          i + 499 > transactions.length
                              ? transactions.length
                              : i + 499));
                    }
                    var transactionRef =
                        dataProvider.getTransactionCollection(accountRef.id);
                    List<WriteBatch> batches = [];
                    for (var list in sublists) {
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      for (var t in list)
                        batch.set<Stabill.Transaction>(transactionRef.doc(), t);
                      batches.add(batch);
                    }
                    await Future.wait(batches.map((e) => e.commit()));
                  }
                }
                break;
              case HomePageAction.Export:
                break;
              case HomePageAction.Settings:
                Navigator.of(context).pushNamed(SettingsPage.routeName);
                break;
            }
          }, itemBuilder: (ctx) {
            return <PopupMenuEntry<HomePageAction>>[
              const PopupMenuItem<HomePageAction>(
                value: HomePageAction.Import,
                child: ListTile(
                  leading: Icon(Icons.file_download_outlined),
                  title: Text("Import Data"),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem<HomePageAction>(
                value: HomePageAction.Export,
                child: ListTile(
                  leading: Icon(Icons.file_upload_outlined),
                  title: Text("Export Data"),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem<HomePageAction>(
                value: HomePageAction.Settings,
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Settings"),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ];
          })
        ],
      ),
      body: PageView(
        controller: controller,
        children: [
          AccountList(
            shouldHideFAB: shouldHideFAB,
          ),
          Center(child: Text("Insights"))
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
              child: Icon(Icons.account_balance),
              spacing: 8,
              spaceBetweenChildren: 8,
              children: [
                  SpeedDialChild(
                    child: Icon(Icons.savings),
                    label: "Add Account",
                    onTap: () => CreateAccountModal.show(context),
                  ),
                  SpeedDialChild(
                      child: Icon(Icons.swap_horiz),
                      label: "Make Transfer",
                      onTap: () => TransferFundsModal.show(context)),
                  SpeedDialChild(
                    child: Icon(Icons.repeat),
                    label: "Recurring Transactions",
                  ),
                ])
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
        ],
        currentIndex: this.index,
        onTap: (int index) {
          setState(() {
            this.index = index;
            controller.jumpToPage(index);
          });
        },
      ),
    );
  }
}
