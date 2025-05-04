import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_application/firebase_options.dart';
import 'package:first_application/views/login_view.dart';
import 'package:flutter/material.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    )
  );
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // switch (snapshot.connectionState) {
        //   case ConnectionState.done:
        //     final user = FirebaseAuth.instance.currentUser;
        //     if (user?.emailVerified ?? false) {
        //       print('Email confirmed');
        //       return Text('Done');
        //     } else {
        //       print('You need to verify tour email');
        //       print(user);
        //       return const VreifyEmailView();
        //     }            
        //   default:
        //     return const Text("Loading...");
        // }
        return const LoginView();
      }),
    );
  }
}


class VreifyEmailView extends StatefulWidget {
  const VreifyEmailView({super.key});

  @override
  State<VreifyEmailView> createState() => _VreifyEmailViewState();
}

class _VreifyEmailViewState extends State<VreifyEmailView> {
  void verifyEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
    print('...');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("You should verify your email"),
        TextButton(
          onPressed: verifyEmail,
          child: const Text('Send email verifiction'),
        ),
      ],
    );
  }
}

