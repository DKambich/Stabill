import 'package:stabill/data/models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AbstractAuthService {
  Stream<AuthState> get authStateChanges;
  AppUser? get currentUser;
  Future<void> resetPassword(String email);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}
