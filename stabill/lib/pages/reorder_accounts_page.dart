import 'package:cloud_firestore/cloud_firestore.dart'
    show QueryDocumentSnapshot;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/providers/preference_provider.dart';

class ReorderAccountsPage extends StatefulWidget {
  static const String routeName = "/reorderaccounts";

  const ReorderAccountsPage({Key? key}) : super(key: key);

  @override
  _ReorderAccountsPageState createState() => _ReorderAccountsPageState();
}

class _ReorderAccountsPageState extends State<ReorderAccountsPage> {
  List<QueryDocumentSnapshot<Account>> _accounts = [];

  @override
  void initState() {
    context.read<DataProvider>().getAccountsCollection().get().then(
          (value) => setState(() {
            _accounts = value.docs;
            final accountOrder =
                context.read<PreferenceProvider>().accountOrder;
            _accounts.sort(
              (a, b) => accountOrder
                  .indexOf(a.id)
                  .compareTo(accountOrder.indexOf(b.id)),
            );
          }),
        );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reorder Accounts"),
      ),
      body: ReorderableListView.builder(
        itemBuilder: (context, index) => Column(
          key: Key('$index'),
          children: [
            ListTile(
              title: Text(_accounts[index].data().name),
              subtitle: Text(_accounts[index].id),
            ),
            const Divider(
              height: 1,
            ),
          ],
        ),
        itemCount: _accounts.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final account = _accounts.removeAt(oldIndex);
            _accounts.insert(newIndex, account);
            context
                .read<PreferenceProvider>()
                .setAccountOrder(_accounts.map((e) => e.id).toList());
          });
        },
      ),
    );
  }
}
