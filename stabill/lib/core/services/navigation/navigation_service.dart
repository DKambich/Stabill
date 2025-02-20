import 'package:go_router/go_router.dart';
import 'package:stabill/config/router.dart';

class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  Future<void> navigateToAccount(String accountId) async =>
      _router.go(Routes.accountRoute(accountId));

  Future<void> navigateToHome() async => _router.go(Routes.home);

  Future<void> navigateToSignIn() async => _router.go(Routes.signIn);

  Future<void> navigateToTransaction(
          String accountId, String transactionId) async =>
      _router.go(Routes.transactionRoute(accountId, transactionId));
}
