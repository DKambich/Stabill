import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/scheduled_transaction.dart';
import 'package:stabill/pages/scheduled_transaction_form_page.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/header_list.dart';
import 'package:stabill/widgets/cards/scheduled_transaction_card.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';

class ScheduledTransactionsPage extends StatefulWidget {
  static const String routeName = "/scheduledTransactions";

  const ScheduledTransactionsPage({Key? key}) : super(key: key);

  @override
  _ScheduledTransactionsPageState createState() =>
      _ScheduledTransactionsPageState();
}

class _ScheduledTransactionsPageState extends State<ScheduledTransactionsPage> {
  late Stream<QuerySnapshot<ScheduledTransaction>> _scheduledStream;

  @override
  void initState() {
    super.initState();
    final DataProvider dataProvider = context.read<DataProvider>();

    _scheduledStream =
        dataProvider.getScheduledTransactionCollectionGroup().snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scheduled Transactions"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () async {
          final ScheduledTransaction? scheduled = await Navigator.pushNamed(
            context,
            ScheduledTransactionModal.routeName,
          );
          if (!mounted) return;
          if (scheduled != null) {
            final DataProvider dataProvider = context.read<DataProvider>();
            await dataProvider.addScheduledTransaction(scheduled);
          }
        },
      ),
      body: StreamBuilder<QuerySnapshot<ScheduledTransaction>>(
        stream: _scheduledStream,
        builder: (context, snapshot) {
          List<QueryDocumentSnapshot<ScheduledTransaction>> scheduledData = [];
          if (snapshot.data != null) scheduledData = snapshot.data!.docs;

          return HeaderList(
            error: snapshot.hasError,
            onError: const Text('Something went wrong'),
            isLoading: snapshot.connectionState == ConnectionState.waiting,
            onLoading: const Center(child: CircularProgressIndicator()),
            onEmpty: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.more_time_rounded,
                        size: 64,
                      ),
                      Text("Schedule a transaction!"),
                    ],
                  ),
                ),
              ],
            ),
            itemBuilder: (context, index) {
              final ScheduledTransaction item = scheduledData[index].data();
              return ScheduledTransactionCard(
                scheduledTransaction: item,
                onSelect: (action) async {
                  switch (action) {
                    case ScheduledTransactionAction.edit:
                      final ScheduledTransaction? scheduled =
                          await Navigator.pushNamed(
                        context,
                        ScheduledTransactionModal.routeName,
                        arguments: item,
                      );
                      if (!mounted) return;
                      if (scheduled != null) {
                        await context
                            .read<DataProvider>()
                            .updateScheduledTransaction(
                              item,
                              scheduled,
                            );
                      }
                      break;
                    case ScheduledTransactionAction.delete:
                      if (await ConfirmDialog.show(
                        context,
                        "Delete Scheduled Transaction?",
                        "Are you sure you want to delete the scheduled transaction '${item.transaction.name}'?",
                      )) {
                        await context
                            .read<DataProvider>()
                            .deleteScheduledTransaction(
                              item,
                            );
                      }
                      break;
                    case null:
                      break;
                  }
                },
              );
            },
            itemCount: scheduledData.length,
            itemHeight: 150,
          );
        },
      ),
    );
  }
}
