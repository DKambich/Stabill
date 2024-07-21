import 'package:firebase_auth/firebase_auth.dart';

class StabillAuthProvider {
  final FirebaseAuth firebaseAuth;

  StabillAuthProvider(this.firebaseAuth);

  Stream<User?> get authState => firebaseAuth.authStateChanges();

  User? get currentUser => firebaseAuth.currentUser;

  Future<bool> deleteAccount(String email, String password) async {
    try {
      await currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );

      await currentUser?.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn({String email = "", String password = ""}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<bool> signUp({String email = "", String password = ""}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
