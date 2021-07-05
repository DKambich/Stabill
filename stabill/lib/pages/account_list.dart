import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stabill/models/account.dart';

class AccountList extends StatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  @override
  Widget build(BuildContext context) {
    List<Account> accounts = [];
    accounts.add(
      Account(name: "Checking", availableBalance: 100, currentBalance: 100),
    );
    accounts.add(
      Account(name: "TCF Checking", availableBalance: 200, currentBalance: 200),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1))),
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
                        text: '\$200',
                        style: new TextStyle(
                            color: 200 >= 0 ? Colors.green : Colors.red)),
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
                        text: '\$300',
                        style: new TextStyle(
                            color: 300 >= 0 ? Colors.green : Colors.red)),
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
                double availableBalance = account.availableBalance;
                double currentBalance = account.currentBalance;

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
                              color: availableBalance >= 0
                                  ? Colors.green
                                  : Colors.red)),
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
                              color: currentBalance >= 0
                                  ? Colors.green
                                  : Colors.red)),
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
