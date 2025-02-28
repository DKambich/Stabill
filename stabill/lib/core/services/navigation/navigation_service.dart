import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:stabill/config/router.dart';

class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  RouterConfig<RouteMatchList> get router => _router;

  Future<void> navigateToAccount(String accountId) async =>
      _router.navigate(Routes.accountRoute(accountId));

  // TODO: Decide whether to use push or go
  Future<void> navigateToAccounts() async => _router.navigate(Routes.accounts);

  Future<void> navigateToHome() async => _router.navigate(Routes.home);

  Future<void> navigateToSignIn() async => _router.navigate(Routes.signIn);

  Future<void> navigateToTransaction(
          String accountId, String transactionId) async =>
      _router.navigate(Routes.transactionRoute(accountId, transactionId));
}
