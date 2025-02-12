import 'dart:async';

import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthService implements AbstractAuthService {
  final StreamController<AuthState> _authController =
      StreamController<AuthState>.broadcast();

  // TODO: Expose this or a mock User object
  String? _mockUserId;

  @override
  Stream<AuthState> get authStateChanges => _authController.stream;

  @override
  Future<void> resetPassword(String email) async {
    // No-op for mock
  }

  @override
  Future<void> signIn(String email, String password) async {
    _mockUserId = "mock-user-id";
    _authController.add(AuthState(AuthChangeEvent.signedIn, null));
  }

  @override
  Future<void> signOut() async {
    _mockUserId = null;
    _authController.add(AuthState(AuthChangeEvent.signedOut, null));
  }
}
