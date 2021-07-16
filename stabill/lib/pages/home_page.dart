import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:stabill/pages/login_page.dart';
import 'package:stabill/widgets/account_dialog.dart';
import 'package:stabill/widgets/account_list.dart';
import 'package:stabill/widgets/transfer_dialog.dart';

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
      resizeToAvoidBottomInset: true,
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
        ],
        onPageChanged: (int index) {
          setState(() {
            this.index = index;
          });
        },
      ),
      floatingActionButton: index == 0
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              tooltip: 'Actions',
              child: Icon(Icons.account_balance),
              spacing: 8,
              spaceBetweenChildren: 8,
              children: [
                  SpeedDialChild(
                    child: Icon(Icons.savings),
                    label: "Add Account",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => NewAccountDialog(),
                      );
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.swap_horiz),
                    label: "Make Transfer",
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25)),
                        ),
                        builder: (_) => TransferDialog(),
                      );
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.repeat),
                    label: "Recurring Transactions",
                  ),
                ])
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
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
