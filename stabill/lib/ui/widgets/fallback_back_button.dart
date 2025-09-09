import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';

class AdaptiveBackButton extends StatelessWidget {
  final String fallbackRoute;

  const AdaptiveBackButton({
    super.key,
    this.fallbackRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    var navigationService = context.read<NavigationService>();
    return BackButton(
      onPressed: () =>
          navigationService.navigateBack(fallbackRoute: fallbackRoute),
    );
  }
}
