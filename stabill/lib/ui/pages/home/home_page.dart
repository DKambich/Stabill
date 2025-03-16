import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/ui/widgets/balance_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<Balance>? balanceStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home Page"),
        ),
        body: Center(
          child: Column(
            children: [
              Card(
                child: GestureDetector(
                  onTap: _goToAccounts,
                  child: StreamBuilder<Balance>(
                      stream: balanceStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading");
                        }

                        if (!snapshot.hasData) {
                          return Text(snapshot.connectionState.toString());
                        }

                        var balance = snapshot.data!;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Accounts",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      BalanceText(
                                        balance: balance.availableInDollars,
                                      ),
                                      const Text("Available")
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      BalanceText(
                                        balance: balance.currentInDollars,
                                      ),
                                      const Text("Current")
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    balanceStream = context.read<AccountService>().getTotalBalance();
    super.initState();
  }

  void _goToAccounts() {
    context.read<NavigationService>().navigateToAccounts();
  }

  void _logout() async {
    await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    final isLoggedOut = !context.read<AuthProvider>().isLoggedIn;

    if (isLoggedOut) {
      context.read<NavigationService>().navigateToSignIn();
    } else {
      // TODO: Show an error
    }
  }
}
