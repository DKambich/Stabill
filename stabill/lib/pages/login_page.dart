import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/pages/home_page.dart';
import 'package:stabill/providers/auth_provider.dart';
import 'package:stabill/widgets/dialogs/reset_password_dialog.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  Future<void> logIn() async {
    if (_formKey.currentState!.validate()) {
      if (await context.read<AuthProvider>().signIn(
                email: emailController.text,
                password: passwordController.text,
              ) ==
          false) {
        Fluttertoast.showToast(
          msg:
              "Login failed, please check your email and password then try again",
        );
      } else if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      }
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      if (await context.read<AuthProvider>().signUp(
                email: emailController.text,
                password: passwordController.text,
              ) ==
          false) {
        Fluttertoast.showToast(
          msg: "Account Creation failed, try again",
        );
      } else if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      }
    }
  }

  void forgotPassword() {
    ResetPasswordDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: "logo",
                        child: SvgPicture.asset(
                          "assets/icon/logo_only.svg",
                          width: logoSize,
                          height: logoSize,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(fieldRadius),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white24,
                          hintText: 'Email',
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: emailValidator,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      dialogFieldSpace,
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(fieldRadius),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white24,
                          hintText: 'Password',
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: passwordValidator,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (val) => logIn(),
                      ),
                      dialogFieldSpace,
                      ElevatedButton(
                        onPressed: logIn,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          primary: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(fieldRadius),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                      dialogFieldSpace,
                      RichText(
                        text: TextSpan(
                          text: "Forgot your password?",
                          recognizer: TapGestureRecognizer()
                            ..onTap = forgotPassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: RichText(
              text: TextSpan(
                text: "Don't have an account?",
                children: [
                  TextSpan(
                    text: " Sign Up",
                    recognizer: TapGestureRecognizer()..onTap = signUp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
                recognizer: TapGestureRecognizer()..onTap = signUp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
