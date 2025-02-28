import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<List<Account>>? accountsStream;
  Stream<Balance>? totalBalanceStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the SignInPage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Home Page"),
        ),
        body: Center(
          child: Column(
            spacing: 24,
            children: [
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
              ),
              ElevatedButton(
                onPressed: _createAccount,
                child: Text('Create Account'),
              ),
              ElevatedButton(
                onPressed: _listenToTotalBalance,
                child: Text('Listen to Balance'),
              ),
              ElevatedButton(
                onPressed: _goToAccounts,
                child: Text('Go To Accounts'),
              ),
              StreamBuilder(
                stream: totalBalanceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SelectableText(snapshot.data.toString());
                  }
                  return SelectableText(snapshot.connectionState.toString());
                },
              ),
              StreamBuilder(
                stream: accountsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!
                          .map((account) => SelectableText(account.toString()))
                          .toList(),
                    );
                  }
                  return Text('');
                },
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    accountsStream = context.read<AccountService>().getAccounts();
    super.initState();
  }

  void _createAccount() async {
    var Result(:data) = await context
        .read<AccountService>()
        .createAccount("Account Name", 12345);

    if (data != null) {
      log(data.toString());
    }
  }

  _goToAccounts() {
    context.read<NavigationService>().navigateToAccounts();
  }

  void _listenToTotalBalance() {
    setState(() {
      totalBalanceStream = context.read<AccountService>().getTotalBalance();
    });
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
