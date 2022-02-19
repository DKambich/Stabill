import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/splash_page.dart';
import 'package:stabill/providers/auth_provider.dart';

class Initializer extends StatefulWidget {
  const Initializer({Key? key}) : super(key: key);

  @override
  _InitializerState createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  late StreamSubscription<User?> authSubscription;

  @override
  void initState() {
    // Listen to the initial sign in state of the user
    authSubscription = context.read<AuthProvider>().authState.listen((user) {
      // Navigate based on the user's sign in state
      final String route =
          user != null ? HomePage.routeName : LoginPage.routeName;
      Navigator.of(context).pushReplacementNamed(route);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    authSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashPage();
  }
}
