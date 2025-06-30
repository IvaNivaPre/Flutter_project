import 'package:first_application/services/auth/auth_service.dart';
import 'package:first_application/views/login_view.dart';
import 'package:first_application/views/notes_view.dart';
import 'package:first_application/views/register_view.dart';
import 'package:first_application/views/verify_email_view.dart';
import 'package:first_application/constants/routes.dart' as routes;
import 'package:flutter/material.dart';
import 'dart:developer' as console show log;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        routes.loginRoute: (context) => const LoginView(),
        routes.registerRoute: (context) => const RegisterView(),
        routes.notesRoute: (context) => const NotesView(),
        routes.verifyEmailRoute: (context) => const VreifyEmailView()
      },
    )
  );
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          final user = AuthService.firebase().currentUser;
          console.log(user.toString());
          if (user == null) return LoginView();
          if (user.isEmailVerified) {
            return NotesView();
          } else {  
            return VreifyEmailView();
          }
          default:
            return const CircularProgressIndicator();
        }
      });
  }
}

