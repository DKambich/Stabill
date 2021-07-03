import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stabill',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.red,
      ),
      home: MyHomePage(title: 'Stabill'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  PageController controller = new PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: controller,
        children: [
          Icon(Icons.savings),
          Icon(Icons.insights),
          Icon(Icons.book),
        ],
        onPageChanged: (int index) {
          if (this.index != index) {
            print("Changed to " + index.toString());
            setState(() {
              this.index = index;
            });
          }
        },
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton(
              onPressed: null,
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
            icon: Icon(Icons.book),
            label: "Accounts",
          ),
        ],
        currentIndex: this.index,
        onTap: (int index) {
          setState(() {
            this.index = index;
            controller.jumpToPage(index);
            // controller.animateToPage(index,
            //     duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
      ),
    );
  }
}
