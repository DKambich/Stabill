import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/widgets/account_dialog.dart';
import 'package:stabill/widgets/account_list.dart';

class HomePage extends StatefulWidget {
  static final String routeName = "/home";

  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  PageController controller = new PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: PageView(
        controller: controller,
        children: [
          AccountList(),
          Center(
            child: ElevatedButton(
              child: Text("Logout"),
              onPressed: () {
                FirebaseAuth.instance.signOut().then(
                      (value) => Navigator.pushReplacementNamed(
                        context,
                        LoginPage.routeName,
                      ),
                    );
              },
            ),
          ),
          Icon(Icons.repeat),
        ],
        onPageChanged: (int index) {
          setState(() {
            this.index = index;
          });
        },
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => NewAccountDialog(),
                );
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: "Recurring Transactions",
          ),
        ],
        currentIndex: this.index,
        onTap: (int index) {
          setState(() {
            this.index = index;
            controller.jumpToPage(index);
          });
        },
      ),
    );
  }
}
