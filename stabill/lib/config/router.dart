import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/ui/pages/account/account_page.dart';
import 'package:stabill/ui/pages/accounts/accounts_page.dart';
import 'package:stabill/ui/pages/auth/sign_in_page.dart';
import 'package:stabill/ui/pages/home/home_page.dart';
import 'package:stabill/ui/pages/transaction/transaction_page.dart';

final router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    if (!context.read<AuthProvider>().isLoggedIn) {
      return Routes.signIn;
    } else {
      return null;
    }
  },
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: Routes.accounts,
      builder: (context, state) => AccountsPage(),
    ),
    GoRoute(
      path: RoutePatterns.account,
      builder: (context, state) => AccountPage(
        accountId: state.pathParameters[RoutePathParameter.account] ?? '',
      ),
    ),
    GoRoute(
      path: RoutePatterns.transaction,
      builder: (context, state) {
        final accountId =
            state.pathParameters[RoutePathParameter.account] ?? '';
        final transactionId =
            state.pathParameters[RoutePathParameter.transaction];
        if (transactionId == 'add') {
          return TransactionPage(
            accountId: accountId,
          );
        } else {
          return TransactionPage(
            accountId: accountId,
            transactionId: transactionId,
          );
        }
      },
    )
  ],
);

class RoutePathParameter {
  static const String account = 'accountId';
  static const String transaction = 'transactionId';
}

class RoutePatterns {
  static const String accountToken = ':${RoutePathParameter.account}';
  static const String transactionToken = ':${RoutePathParameter.transaction}';

  static const String account = '/accounts/$accountToken';
  static const String transaction =
      '${RoutePatterns.account}/transaction/$transactionToken'; // updated
}

class Routes {
  // Static routes
  static const String signIn = '/signin';
  static const String home = '/';
  static const String accounts = '/accounts';

  // Dynamic routes
  static String account(String accountId) =>
      RoutePatterns.account.replaceAll(RoutePatterns.accountToken, accountId);

  static String addTransaction(String accountId) =>
      transaction(accountId, 'add');

  static String transaction(String accountId, String transactionId) =>
      RoutePatterns.transaction
          .replaceAll(RoutePatterns.accountToken, accountId)
          .replaceAll(RoutePatterns.transactionToken, transactionId);
}

extension GoRouteExtension on GoRouter {
  navigate<T>(String route) => kIsWeb ? go(route) : push(route);
}
