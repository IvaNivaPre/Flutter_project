import 'package:first_application/services/auth/auth_provider.dart';
import 'package:first_application/services/auth/auth_user.dart';
import 'package:first_application/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<void> initialize() {
    return provider.initialize();
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password
    }) {
    return provider.createUser(
      email: email,
      password: password
    );
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
      required String email,
      required String password
    }) {
    return provider.logIn(
      email: email,
      password: password
    );
  }

  @override
  Future<void> logOut() {
    return provider.logOut();
  }

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }  
}
