import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/pages/splash_page.dart';
import 'package:stabill/pages/transactions_page.dart';

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
        HomePage.routeName: (_ctx) => HomePage(title: 'Stabill'),
        LoginPage.routeName: (_ctx) => LoginPage(),
        TransactionsPage.routeName: (_ctx) =>
            TransactionsPage(accountID: "Test ID")
      },
    );
  }
}
