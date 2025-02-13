import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/data/models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService implements AbstractAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((event) => event);

  @override
  AppUser? get currentUser =>
      AppUser.fromSupabaseUser(_supabase.auth.currentUser);

  @override
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
