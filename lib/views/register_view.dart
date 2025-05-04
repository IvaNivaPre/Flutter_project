import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';


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
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password1
      );
      _infoField.value = "Register succeed";
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _infoField.value = 'Password is too weak';
          print('Password is too weak');
        case 'email-already-in-use':
          _infoField.value = 'This email is already used';
          print('This email is already used');
        case 'invalid-email':
          _infoField.value = 'This is invalid email';
          print('This is invalid email');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Expanded(
          child: Center(
            child: ValueListenableBuilder<String>(
              valueListenable: _infoField,
              builder: (context, value, child) => Text(value)
            )
          ),
        )
      ],
    );
  }
}