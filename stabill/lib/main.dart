import 'package:flutter/material.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/splash_page.dart';
import 'package:stabill/pages/transactions_page.dart';
import 'package:stabill/widgets/transaction_modal.dart';

void main() {
  runApp(Stabill());
}

class Stabill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stabill',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.red,
      ),
      home: SplashPage(),
      routes: <String, WidgetBuilder>{
        TransactionModal.routeName: (_ctx) => TransactionModal()
      },
      onGenerateRoute: (settings) {
        final String routeName = settings.name ?? "";
        if (routeName == HomePage.routeName) {
          return MaterialPageRoute(
            builder: (_ctx) => HomePage(title: 'Stabill'),
          );
        } else if (routeName == LoginPage.routeName) {
          return MaterialPageRoute(
            builder: (_ctx) => LoginPage(),
          );
        } else if (routeName == TransactionsPage.routeName) {
          final args = settings.arguments as TransactionArguments;
          return MaterialPageRoute(
            builder: (_ctx) => TransactionsPage(
              accountID: args.accountID,
              account: args.account,
            ),
          );
        } else if (routeName == TransactionModal.routeName) {
          return MaterialPageRoute(builder: (_ctx) => TransactionModal());
        }

        // The code only supports
        // PassArgumentsScreen.routeName right now.
        // Other values need to be implemented if we
        // add them. The assertion here will help remind
        // us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere
        // in the framework.
        assert(false, 'Need to implement $routeName');
        return null;
      },
    );
  }
}
