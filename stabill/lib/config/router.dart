import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/ui/pages/account/account_page.dart';
import 'package:stabill/ui/pages/accounts/accounts_page.dart';
import 'package:stabill/ui/pages/auth/sign_in_page.dart';
import 'package:stabill/ui/pages/home/home_page.dart';

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
        accountId: state.pathParameters[RoutePatterns.accountToken] ?? '',
      ),
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
  static const String transaction = '/transaction/$transactionToken';
}

class Routes {
  // Static routes
  static const String signIn = '/signin';
  static const String home = '/';
  static const String accounts = '/accounts';

  // Dynamic routes
  static String accountRoute(String accountId) =>
      RoutePatterns.account.replaceAll(RoutePatterns.accountToken, accountId);

  static String transactionRoute(String accountId, String transactionId) =>
      '${accountRoute(accountId)}${RoutePatterns.transaction.replaceAll(RoutePatterns.transactionToken, transactionId)}';
}

extension GoRouteExtension on GoRouter {
  navigate<T>(String route) => kIsWeb ? go(route) : push(route);
}
