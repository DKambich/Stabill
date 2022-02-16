import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/providers/messaging_provider.dart';
import 'package:stabill/providers/preference_provider.dart';

class RootProvider extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  const RootProvider({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => AuthProvider(FirebaseAuth.instance),
      child: ProxyProvider<AuthProvider, DataProvider>(
        update: (context, user, data) => DataProvider(
          FirebaseFirestore.instance,
          context.watch<AuthProvider>().currentUser,
        ),
        child: ProxyProvider<AuthProvider, MessageProvider>(
          update: (context, user, data) => MessageProvider(
            FirebaseMessaging.instance,
            context.watch<AuthProvider>().currentUser,
          ),
          child: MaterialApp(
            home: ChangeNotifierProvider(
              create: (_) => PreferenceProvider(),
              child: Builder(builder: builder),
            ),
          ),
        ),
      ),
    );
  }
}
