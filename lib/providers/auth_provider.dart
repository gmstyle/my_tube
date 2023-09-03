import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await googleSignIn.signIn();
    } catch (e) {
      log(e.toString());
      return Future.error(e);
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await googleSignIn.signInSilently();
    } catch (e) {
      log(e.toString());
      return Future.error(e);
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (e) {
      log(e.toString());
      return Future.error(e);
    }
  }
}
