import 'package:first_application/services/auth/auth_exceptions.dart';
import 'package:first_application/services/auth/auth_provider.dart';
import 'package:first_application/services/auth/auth_user.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
final MockAuthProvider provider = MockAuthProvider();

  group(
    'Mock authentication',
    () {
      test(
        'Should be initialized',
        () {
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>())
          );
        }
      );

      test(
        'Can be initialized',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        }
      );

      test(
        'User should be null after initialization',
        () async {
          expect(provider.user, null);
        }
      );

      test(
        'Should be able to initialize in 2 secs',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
        timeout: const Timeout(Duration(seconds: 2))
      );

      test(
        'Create user should delegate to logIn function',
        () async {
          final badUser = provider.createUser(
            email: 'example@gmail.com',
            password: '1234'
          );
          expect(
            badUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>())
          );

          final goodUser = provider.createUser(
            email: 'exampl@gmail.com',
            password: '1234'
          );
          expect(provider.user, goodUser);
        },
        timeout: const Timeout(Duration(seconds: 2))
      );
    }
  );
}


class NotInitializedException implements Exception {}


class MockAuthProvider implements AuthProvider {
  AuthUser? user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'example@gmail.com') throw UserNotFoundAuthException();
    user = AuthUser(isEmailVerified: false);
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    user = AuthUser(isEmailVerified: true);
  }
  
}