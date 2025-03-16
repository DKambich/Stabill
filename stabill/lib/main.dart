import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/data/repository/database_repository.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const Stabill());
}

class Stabill extends StatefulWidget {
  const Stabill({super.key});

  @override
  State<Stabill> createState() => _StabillState();
}

class _StabillState extends State<Stabill> {
  late final NavigationService _navigationService = NavigationService(router);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<NavigationService>.value(value: _navigationService),
        Provider<AccountService>(
          create: (_) => AccountService(DatabaseRepository.instance),
        ),
      ],
      child: MaterialApp.router(
        // TODO: Decide if this should be scoped or not
        scrollBehavior: MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        routerConfig: _navigationService.router,
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
      ),
    );
  }

  void initialize() {}

  @override
  void initState() {
    super.initState();
    initialize();
  }
}
