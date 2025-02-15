import 'package:go_router/go_router.dart';
import 'package:stabill/ui/pages/auth/sign_in_page.dart';
import 'package:stabill/ui/pages/home/home_page.dart';

final goRouter = GoRouter(routes: _routes);

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
