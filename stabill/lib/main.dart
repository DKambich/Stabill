import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/initializer.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/settings_page.dart';
import 'package:stabill/pages/transactions_page.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/providers/root_provider.dart';
import 'package:stabill/widgets/modals/transaction_form_modal.dart';

void main() {
  runApp(MaterialApp(home: Stabill()));
}

class Stabill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RootProvider(
      builder: (context) {
        return MaterialApp(
          theme: context.read<PreferenceProvider>().getTheme(
                context,
                context.watch<PreferenceProvider>().themeMode,
              ),
          title: 'Stabill',
          home: Initializer(),
          routes: <String, WidgetBuilder>{
            TransactionModal.routeName: (_ctx) => TransactionModal()
          },
          onGenerateRoute: generateRoute,
        );
      },
    );
  }

  MaterialPageRoute? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? "";
    if (routeName == HomePage.routeName) {
      return MaterialPageRoute(
        builder: (_) => HomePage(),
      );
    } else if (routeName == LoginPage.routeName) {
      return MaterialPageRoute(
        builder: (_) => LoginPage(),
      );
    } else if (routeName == TransactionsPage.routeName) {
      final args = settings.arguments as TransactionArguments;
      return MaterialPageRoute(
        builder: (_) => TransactionsPage(
          accountID: args.accountID,
          account: args.account,
        ),
      );
    } else if (routeName == TransactionModal.routeName) {
      return MaterialPageRoute(builder: (_ctx) => TransactionModal());
    } else if (routeName == SettingsPage.routeName) {
      return MaterialPageRoute(builder: (_) => SettingsPage());
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
  }
}
