import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AbstractAuthService {
  Stream<AuthState> get authStateChanges;
  Future<void> resetPassword(String email);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}
