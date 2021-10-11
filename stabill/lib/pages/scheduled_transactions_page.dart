import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/scheduled_transaction.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/header_list.dart';
import 'package:stabill/widgets/cards/scheduled_transaction_card.dart';
import 'package:stabill/widgets/modals/scheduled_transaction_form_modal.dart';

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
        child: const Icon(Icons.add),
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
      body: HeaderList(
        listBody: StreamBuilder<QuerySnapshot<ScheduledTransaction>>(
          stream: _scheduledStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final scheduledData = snapshot.data!.docs;
            if (scheduledData.isEmpty) {
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

            return ListView.builder(
              itemCount: scheduledData.length,
              itemBuilder: (context, index) {
                final ScheduledTransaction item = scheduledData[index].data();
                return ScheduledTransactionCard(scheduledTransaction: item);
              },
            );
          },
        ),
      ),
    );
  }
}
