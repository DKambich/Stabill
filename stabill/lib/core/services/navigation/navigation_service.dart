import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/data/models/transaction.dart';

class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  RouterConfig<RouteMatchList> get router => _router;

  void finishTransactionEdit(
    String accountId,
    Transaction transaction,
  ) {
    _router.go(
      Routes.transaction(accountId, transaction.id!),
      extra: transaction,
    );
  }

  void goToAccount(String accountId) => _router.go(Routes.account(accountId));

  Future<void> navigateBack({
    String fallbackRoute = Routes.home,
  }) async {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(fallbackRoute);
    }
  }

  Future<void> navigateToAccount(String accountId) async =>
      _router.navigate(Routes.account(accountId));

  Future<void> navigateToAccounts() async => _router.navigate(Routes.accounts);

  Future<void> navigateToAccountSettings() async =>
      _router.navigate(Routes.accountSettings);

  Future<void> navigateToAddTransaction(String accountId) async =>
      _router.navigate(Routes.addTransaction(accountId));

  Future<void> navigateToArchivedAccounts() async =>
      _router.navigate(Routes.archivedAccounts);

  Future<void> navigateToEditTransaction(
    String accountId,
    String transactionId, {
    Transaction? transaction,
  }) async {
    _router.go(
      Routes.editTransaction(accountId, transactionId),
      extra: transaction,
    );
  }

  Future<void> navigateToHome() async => _router.navigate(Routes.home);

  Future<void> navigateToSettings() async => _router.navigate(Routes.settings);

  Future<void> navigateToSignIn() async => _router.navigate(Routes.signIn);

  Future<void> navigateToTransaction(
    String accountId,
    String transactionId, {
    Transaction? transaction,
  }) async {
    final route = Routes.transaction(accountId, transactionId);
    if (kIsWeb) {
      _router.go(route, extra: transaction);
    } else {
      await _router.push<void>(route, extra: transaction);
    }
  }
}
