import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/ui/pages/auth/sign_in_page.dart';
import 'package:stabill/ui/pages/home/home_page.dart';

final goRouter = GoRouter(
  routes: _routes,
  redirect: (BuildContext context, GoRouterState state) {
    if (!context.read<AuthProvider>().isLoggedIn) {
      return '/sign-in';
    } else {
      return null;
    }
  },
);

final _routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: '/sign-in',
    builder: (context, state) => SignInPage(),
  ),
];
