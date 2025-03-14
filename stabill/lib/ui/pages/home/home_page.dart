import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              )
            ],
          ),
        ));
  }

  void _createAccount() async {
    var result = await context
        .read<AccountService>()
        .createAccount("Account Name", 12345);
    if (result.isSuccess) {
      var account = result.data!;
      log(account.toString());
    }
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
