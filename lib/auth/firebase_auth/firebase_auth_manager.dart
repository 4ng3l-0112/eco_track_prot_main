import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_manager.dart';

import '/backend/backend.dart';
import 'anonymous_auth.dart';
import 'apple_auth.dart';
import 'email_auth.dart';
import 'firebase_user_provider.dart';
import 'google_auth.dart';
import 'jwt_token_auth.dart';
import 'github_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

export '../base_auth_user_provider.dart';

class FirebasePhoneAuthManager extends ChangeNotifier {
  bool? _triggerOnCodeSent;
  FirebaseAuthException? phoneAuthError;
  // Set when using phone verification (after phone number is provided).
  String? phoneAuthVerificationCode;
  // Set when using phone sign in in web mode (ignored otherwise).
  ConfirmationResult? webPhoneAuthConfirmationResult;
  // Used for handling verification codes for phone sign in.
  void Function(BuildContext)? _onCodeSent;

  bool get triggerOnCodeSent => _triggerOnCodeSent ?? false;
  set triggerOnCodeSent(bool val) => _triggerOnCodeSent = val;

  void Function(BuildContext) get onCodeSent =>
      _onCodeSent == null ? (_) {} : _onCodeSent!;
  set onCodeSent(void Function(BuildContext) func) => _onCodeSent = func;

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}

class FirebaseAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        AppleSignInManager,
        AnonymousSignInManager,
        JwtSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  // Set when using phone verification (after phone number is provided).
  String? _phoneAuthVerificationCode;
  // Set when using phone sign in in web mode (ignored otherwise).
  ConfirmationResult? _webPhoneAuthConfirmationResult;
  FirebasePhoneAuthManager phoneAuthManager = FirebasePhoneAuthManager();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future signOut({required BuildContext context}) async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
        ),
      );
    }
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (_firebaseAuth.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user currently signed in.'),
          ),
        );
        return;
      }
      await _firebaseAuth.currentUser!.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User account successfully deleted.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
        ),
      );
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
      await updateUserDocument(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Too long since most recent sign in. Sign in again before updating your email.')),
        );
      }
    }
  }

  @override
  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update password attempted with no logged in user!');
        return;
      }
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message!}')),
        );
      }
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message!}'),
        ),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        () => emailSignInFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        () => emailCreateAccountFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> signInAnonymously(
    BuildContext context,
  ) =>
      _signInOrCreateAccount(
        anonymousSignInFunc,
        'ANONYMOUS',
      );

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) =>
      _signInOrCreateAccount(
        () => appleSignIn(context),
        'APPLE',
      );

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) =>
      _signInOrCreateAccount(
        () => _handleGoogleSignIn(context),
        'GOOGLE',
      );

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) =>
      _signInOrCreateAccount(
        githubSignInFunc,
        'GITHUB',
      );

  @override
  Future<BaseAuthUser?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  ) =>
      _signInOrCreateAccount(
        () => jwtTokenSignIn(jwtToken),
        'JWT',
      );

  void handlePhoneAuthStateChanges(BuildContext context) {
    phoneAuthManager.addListener(() {
      if (!context.mounted) {
        return;
      }

      if (phoneAuthManager.triggerOnCodeSent) {
        phoneAuthManager.onCodeSent(context);
        phoneAuthManager
            .update(() => phoneAuthManager.triggerOnCodeSent = false);
      } else if (phoneAuthManager.phoneAuthError != null) {
        final e = phoneAuthManager.phoneAuthError!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.message!}'),
        ));
        phoneAuthManager.update(() => phoneAuthManager.phoneAuthError = null);
      }
    });
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    phoneAuthManager.update(() => phoneAuthManager.onCodeSent = onCodeSent);
    if (kIsWeb) {
      phoneAuthManager.webPhoneAuthConfirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
      phoneAuthManager.update(() => phoneAuthManager.triggerOnCodeSent = true);
      return;
    }
    final completer = Completer<bool>();
    // If you'd like auto-verification, without the user having to enter the SMS
    // code manually. Follow these instructions:
    // * For Android: https://firebase.google.com/docs/auth/android/phone-auth?authuser=0#enable-app-verification (SafetyNet set up)
    // * For iOS: https://firebase.google.com/docs/auth/ios/phone-auth?authuser=0#start-receiving-silent-notifications
    // * Finally modify verificationCompleted below as instructed.
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout:
          const Duration(seconds: 0), // Skips Android's default auto-verification
      verificationCompleted: (phoneAuthCredential) async {
        await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        phoneAuthManager.update(() {
          phoneAuthManager.triggerOnCodeSent = false;
          phoneAuthManager.phoneAuthError = null;
        });
        // If you've implemented auto-verification, navigate to home page or
        // onboarding page here manually. Uncomment the lines below and replace
        // DestinationPage() with the desired widget.
        // await Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => DestinationPage()),
        // );
      },
      verificationFailed: (e) {
        phoneAuthManager.update(() {
          phoneAuthManager.triggerOnCodeSent = false;
          phoneAuthManager.phoneAuthError = e;
        });
        completer.complete(false);
      },
      codeSent: (verificationId, _) {
        phoneAuthManager.update(() {
          phoneAuthManager.phoneAuthVerificationCode = verificationId;
          phoneAuthManager.triggerOnCodeSent = true;
          phoneAuthManager.phoneAuthError = null;
        });
        completer.complete(true);
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  }) {
    if (kIsWeb) {
      return _signInOrCreateAccount(
        () => phoneAuthManager.webPhoneAuthConfirmationResult!.confirm(smsCode),
        'PHONE',
      );
    } else {
      final authCredential = PhoneAuthProvider.credential(
        verificationId: phoneAuthManager.phoneAuthVerificationCode!,
        smsCode: smsCode,
      );
      return _signInOrCreateAccount(
        () => FirebaseAuth.instance.signInWithCredential(authCredential),
        'PHONE',
      );
    }
  }

  Future<UserCredential?> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign in with Google. Please try again.'),
        ),
      );
      return null;
    }
  }

  /// Tries to sign in or create an account using Firebase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    Future<UserCredential?> Function() signInFunc,
    String provider,
  ) async {
    try {
      print('Attempting sign in with $provider...'); 
      final userCredential = await signInFunc();
      print('Sign in result: ${userCredential?.user?.uid}');
      if (userCredential?.user != null) {
        await maybeCreateUser(userCredential!.user!);
      }
      return userCredential == null
          ? null
          : EcoTrackProtFirebaseUser.fromUserCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      final errorMsg = switch (e.code) {
        'email-already-in-use' =>
          'Error: The email is already in use by a different account',
        'INVALID_LOGIN_CREDENTIALS' =>
          'Error: The supplied auth credential is incorrect, malformed or has expired',
        _ => 'Error: ${e.message!}',
      };
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return null;
    }
  }

  Future<UserCredential?> appleSignIn(BuildContext context) async {
    return null;
  
    // Your apple sign in logic
  }
}
