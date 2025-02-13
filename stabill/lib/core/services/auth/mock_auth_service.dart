import 'dart:async';

import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/data/models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthService implements AbstractAuthService {
  final StreamController<AuthState> _authController =
      StreamController<AuthState>.broadcast();

  AppUser? _mockUser;

  @override
  Stream<AuthState> get authStateChanges => _authController.stream;

  @override
  AppUser? get currentUser => _mockUser;

  @override
  Future<void> resetPassword(String email) async {
    // No-op for mock
  }

  @override
  Future<void> signIn(String email, String password) async {
    _mockUser = AppUser(
      id: "mock-user-id",
      email: email,
    );
    _authController.add(AuthState(AuthChangeEvent.signedIn, null));
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    _authController.add(AuthState(AuthChangeEvent.signedOut, null));
  }
}
