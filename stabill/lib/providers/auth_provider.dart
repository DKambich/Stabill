import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider {
  final FirebaseAuth firebaseAuth;

  AuthProvider(this.firebaseAuth);

  Stream<User?> get authState => firebaseAuth.authStateChanges();

  User? get currentUser => firebaseAuth.currentUser;

  Future<String> signUp({String email = "", String password = ""}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Signed up!";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An exception occured at sign up";
    }
  }

  Future<String> signIn({String email = "", String password = ""}) async {
    try {
      UserCredential cred = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(cred.user);
      return "Signed in!";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An exception occured at sign in";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteAccount(String email, String password) async {
    try {
      await currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
      await currentUser?.delete();
    } catch (e) {
      rethrow;
    }
  }
}
