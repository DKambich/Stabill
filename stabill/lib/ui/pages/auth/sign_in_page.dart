import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/data/models/app_user.dart';
import 'package:stabill/providers/auth_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppUser? loggedInUser = context.watch<AuthProvider>().currentUser;
    bool loggedIn = loggedInUser != null;

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the SignInPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Sign In"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      try {
        await context.read<AuthProvider>().signIn(email, password);
      } catch (error) {
        // Show an error
        log("Login Failed");
        return;
      }

      if (!mounted) return;

      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

      if (isLoggedIn) {
        log("Logged In User: ${context.read<AuthProvider>().currentUser}");
        context.read<NavigationService>().navigateToHome();
      } else {
        // TODO: Show an error
      }
    }
  }
}
