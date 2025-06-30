// ignore_for_file: use_build_context_synchronously

import 'package:first_application/services/auth/auth_exceptions.dart';
import 'package:first_application/services/auth/auth_service.dart';
import 'package:flutter/material.dart'; 
import 'package:first_application/constants/routes.dart' as routes;
import 'package:first_application/utilities/show_error_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final ValueNotifier<String> _infoField = ValueNotifier<String>("");


  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void loginUser() async {  
    final email = _email.text;
    final password = _password.text;

    try {
      await AuthService.firebase().logIn(
        email: email,
        password: password
      );
      final user = AuthService.firebase().currentUser;
      if (user?.isEmailVerified ?? false) {
        _infoField.value = "Login succeed";
        Navigator.of(context).pushNamedAndRemoveUntil(
          routes.notesRoute,
          (_) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          routes.verifyEmailRoute,
          (_) => false,
        );
      }

      
    } on UserNotFoundAuthException {
      _infoField.value = "No user with such email";
      await showErrorDialog(context, "No user with such email");
    } on WrongPasswordAuthException {
      _infoField.value = "Wrong password";
      await showErrorDialog(context, "Wrong password");
    } on GenericAuthException {
      _infoField.value = "Authentication error";
      await showErrorDialog(context, "Authentication error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "Enter your password"
            ),
          ),
          TextButton(
            onPressed: loginUser,
            child: const Text("Login")
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                routes.registerRoute,
                (route) => false,
              );
            },
            child: Text("Not Registered yet? Register here!")
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
