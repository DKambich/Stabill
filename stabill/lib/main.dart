import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/settings_page.dart';
import 'package:stabill/pages/transactions_page.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/providers/root_provider.dart';
import 'package:stabill/utilities/initializer.dart';
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
          home: const Initializer(),
          onGenerateRoute: generateRoute,
        );
      },
    );
  }

  MaterialPageRoute? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? "";
    if (routeName == HomePage.routeName) {
      return MaterialPageRoute(
        builder: (_) => const HomePage(),
      );
    } else if (routeName == LoginPage.routeName) {
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
      );
    } else if (routeName == TransactionsPage.routeName) {
      if (settings.arguments != null) {
        final Account args = settings.arguments! as Account;
        return MaterialPageRoute(
          builder: (_) => TransactionsPage(account: args),
        );
      }
      assert(false, 'Need to pass account argument to $routeName');
    } else if (routeName == TransactionModal.routeName) {
      return MaterialPageRoute<Transaction>(
        builder: (_) => const TransactionModal(),
        fullscreenDialog: true,
      );
    } else if (routeName == SettingsPage.routeName) {
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    } else {
      assert(false, 'Need to implement $routeName');
    }

    return null;
  }
}
