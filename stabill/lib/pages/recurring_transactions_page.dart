import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/recurring_transaction.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/widgets/modals/recurring_transaction_form_modal.dart';

class RecurringTransactionsPage extends StatefulWidget {
  static const String routeName = "/recurringTransactions";

  const RecurringTransactionsPage({Key? key}) : super(key: key);

  @override
  _RecurringTransactionsPageState createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  late Stream<QuerySnapshot<RecurringTransaction>> _recurringStream;

  @override
  void initState() {
    super.initState();
    final DataProvider dataProvider = context.read<DataProvider>();

    final recurringCol = dataProvider.getRecurringTransactionCollectionGroup();
    _recurringStream = recurringCol.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Transactions"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, RecurringTransactionModal.routeName);
        },
      ),
      body: StreamBuilder<QuerySnapshot<RecurringTransaction>>(
        stream: _recurringStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var recurringData = snapshot.data!.docs;
          recurringData.clear();
          if (recurringData.isEmpty) {
            // Figure out why all this rendering is weird
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.more_time_outlined,
                        size: 64,
                      ),
                      Text("Schedule a transaction!"),
                    ],
                  ),
                ),
              ],
            );
          }

          // Filter data to be only RecurringTransactions from the user
          recurringData = recurringData
              .where(
                (data) =>
                    data.reference.parent.parent!.parent.parent!.id ==
                    context.read<DataProvider>().user!.uid,
              )
              .toList();

          return ListView.builder(
            itemCount: recurringData.length,
            itemBuilder: (context, index) {
              final RecurringTransaction item = recurringData[index].data();
              return Card(
                child: Text(item.transaction.name),
              );
            },
          );
        },
      ),
    );
  }
}
