import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/providers/data_provider.dart';

class RootProvider extends StatelessWidget {
  final Widget child;
  const RootProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => AuthProvider(FirebaseAuth.instance),
      child: ProxyProvider<AuthProvider, DataProvider>(
        update: (context, user, data) => DataProvider(
          FirebaseFirestore.instance,
          context.watch<AuthProvider>().currentUser,
        ),
        child: child,
      ),
    );
  }
}
