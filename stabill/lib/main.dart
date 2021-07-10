import 'package:flutter/material.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/splash_page.dart';

void main() {
  runApp(Stabill());
}

class Stabill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stabill',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.red,
      ),
      home: SplashPage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomePage(title: 'Stabill'),
      },
    );
  }
}
