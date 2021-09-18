import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:stabill/providers/data_provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription<User?>? stream;

  @override
  void initState() {
    Firebase.initializeApp().then((FirebaseApp firebaseApp) {
      stream = FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          toLogin();
        } else {
          toHome();
        }
      });
    }).onError((err, stack) {
      print(err);
    });
    super.initState();
  }

  void toHome() {
    // Deregister the stream
    stream?.onData((data) {});
    print('User is signed in!');
    Navigator.pushReplacementNamed(context, HomePage.routeName);
  }

  void toLogin() {
    // Deregister the stream
    stream?.onData((data) {});
    print('User is currently signed out!');
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
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
