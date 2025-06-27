import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:first_application/constants/routes.dart' as routes;
import 'package:first_application/utilities/show_error_dialog.dart';
import 'dart:developer' as console show log;


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password1;
  late final TextEditingController _password2;
  final ValueNotifier<String> _infoField = ValueNotifier<String>("");


  @override
  void initState() {
    _email = TextEditingController();
    _password1 = TextEditingController();
    _password2 = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password1.dispose();
    _password2.dispose();
    super.dispose();
  }

  void registerUser() async {  
    final email = _email.text;
    final password1 = _password1.text;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password1
      );
      _infoField.value = "Register succeed";
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      Navigator.of(context).pushNamed(
        routes.verifyEmailRoute,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _infoField.value = 'Password is too weak';
          await showErrorDialog(context, 'Password is too weak');
        case 'email-already-in-use':
          _infoField.value = 'This email is already used';
          await showErrorDialog(context, 'This email is already used');
        case 'invalid-email':
          _infoField.value = 'This is invalid email';
          await showErrorDialog(context, 'This is invalid email');
        default:
          await showErrorDialog(context, "Error: ${e.toString()}");
      }
    } catch (e) {
      console.log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email"
            ),
          ),
          TextField(
            controller: _password1,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "Enter your password"
            ),
          ),
          TextField(
            controller: _password2,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "Repeat your password"
            ),
          ),
          TextButton(
            onPressed: () {
              if (_password1.text != _password2.text) {
                _infoField.value = "Passwords doesen't match";
                return;
              }
              registerUser();
            },
            child: const Text("Register")
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                routes.loginRoute,
                (route) => false,
              );
            },
            child: const Text("Have an account? Login here!"),
          ),
          Expanded(
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: _infoField,
                builder: (context, value, child) => Text(value)
              )
            ),
          )
        ],
      ),
    );
  }
}