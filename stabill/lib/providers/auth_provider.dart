import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider {
  final FirebaseAuth firebaseAuth;

  AuthProvider(this.firebaseAuth);

  Stream<User?> get authState => firebaseAuth.authStateChanges();

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
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Signed in!";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An exception occured at sign in";
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
