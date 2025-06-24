import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class VreifyEmailView extends StatefulWidget {
  const VreifyEmailView({super.key});

  @override
  State<VreifyEmailView> createState() => _VreifyEmailViewState();
}

class _VreifyEmailViewState extends State<VreifyEmailView> {
  void verifyEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login/',
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text("You should verify your email"),
          TextButton(
            onPressed: verifyEmail,
            child: const Text('Send email verifiction'),
          ),
        ],
      ),
    );
  }
}