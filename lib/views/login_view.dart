import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

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
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      _infoField.value = "Login succeed";
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found' || 'invalid-email':
          _infoField.value = "No user with such email";
          print("User not found");
        case 'wrong-password':
          _infoField.value = "Wrong password";
          print("Wrong password");
      }
    } catch (e) {
      print(e);
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
                '/register/',
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