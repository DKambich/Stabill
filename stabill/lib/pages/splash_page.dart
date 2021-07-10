import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stabill/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Firebase.initializeApp().then((FirebaseApp firebaseApp) {
      print("${firebaseApp.name} Initialized");
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('User is currently signed out!');
          FirebaseAuth.instance.signInAnonymously();
        } else {
          print('User is signed in!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(title: "Stabill"),
            ),
          );
        }
      }).onError((err) => print(err));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}
