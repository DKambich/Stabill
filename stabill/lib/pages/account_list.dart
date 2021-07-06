import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stabill/models/account.dart';

class AccountList extends StatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  Color getBalanceColor(double balance) {
    return balance > 0
        ? Colors.green
        : balance < 0
            ? Colors.red
            : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    List<Account> accounts = [];
    accounts.add(
      Account(
          name: "Checking", availableBalance: 100.00, currentBalance: 100.00),
    );
    accounts.add(
      Account(
          name: "TCF Checking", availableBalance: 200.0, currentBalance: 200.0),
    );

    double totalCurrentBalance = 0;
    double totalAvailableBalance = 0;

    accounts.forEach((element) {
      totalCurrentBalance += element.currentBalance;
      totalAvailableBalance += element.availableBalance;
    });

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 0.25),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'Current: '),
                    new TextSpan(
                      text: '\$${totalCurrentBalance.toStringAsFixed(2)}',
                      style: new TextStyle(
                        color: getBalanceColor(totalCurrentBalance),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'Available: '),
                    new TextSpan(
                      text: '\$${totalAvailableBalance.toStringAsFixed(2)}',
                      style: new TextStyle(
                        color: getBalanceColor(totalCurrentBalance),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (ctx, index) {
                final Account account = accounts[index];

                String accountName = account.name;
                String availableBalance =
                    account.availableBalance.toStringAsFixed(2);
                String currentBalance =
                    account.currentBalance.toStringAsFixed(2);

                RichText availableText = new RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      new TextSpan(text: 'Available: '),
                      new TextSpan(
                        text: '\$$availableBalance',
                        style: new TextStyle(
                          color: getBalanceColor(totalCurrentBalance),
                        ),
                      ),
                    ],
                  ),
                );

                RichText currentText = new RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      new TextSpan(text: 'Current: '),
                      new TextSpan(
                        text: '\$$currentBalance',
                        style: new TextStyle(
                          color: getBalanceColor(totalCurrentBalance),
                        ),
                      ),
                    ],
                  ),
                );

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              accountName,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Column(
                            children: [availableText, currentText],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
