import 'package:flutter/material.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts'),
        leading: AdaptiveBackButton(
          fallbackRoute: Routes.home,
        ),
      ),
    );
  }
}
