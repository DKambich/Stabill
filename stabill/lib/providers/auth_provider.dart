import 'package:flutter/foundation.dart';
import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/auth_service.dart';
import 'package:stabill/data/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  late final AbstractAuthService _authService;

  AuthProvider() {
    _authService = AuthService.instance;

    _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  AppUser? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
