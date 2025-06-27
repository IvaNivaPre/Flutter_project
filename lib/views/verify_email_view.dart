import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:first_application/constants/routes.dart' as routes;


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
      routes.loginRoute,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text("We've sent you an email verification"),
          const Text("If you haven't recieved a verification, press the button"),
          TextButton(
            onPressed: verifyEmail,
            child: const Text('Send email verifiction'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                routes.registerRoute,
                (_) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}