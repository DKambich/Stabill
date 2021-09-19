import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/splash_page.dart';
import 'package:stabill/providers/auth_provider.dart';

class Initializer extends StatelessWidget {
  const Initializer({Key? key}) : super(key: key);

  Future<void> initalize() async {
    print("Initializing App...");
    await Firebase.initializeApp();
    await Future.delayed(Duration(milliseconds: 2000));
    print("App Initalized Successfully");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initalize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPage();
        }
        return StreamBuilder<User?>(
          stream: context.read<AuthProvider>().authState,
          builder: (context, snapshot) {
            Widget page;
            if (snapshot.connectionState == ConnectionState.waiting) {
              page = SplashPage();
            } else {
              final User? user = snapshot.data;
              page = (user != null ? HomePage() : LoginPage());
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: page,
              transitionBuilder: (child, animation) {
                const begin = Offset(0.0, 1.0), end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          },
        );
      },
    );
  }
}
