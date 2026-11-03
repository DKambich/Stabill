import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: AdaptiveBackButton(fallbackRoute: Routes.home),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Accounts'),
            subtitle: const Text('Reorder accounts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.read<NavigationService>().navigateToAccountSettings(),
          ),
        ],
      ),
    );
  }
}
