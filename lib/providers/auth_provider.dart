import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import 'base_provider.dart';

class AuthProvider {
  final GoogleSignIn googleSignIn = BaseProvider.googleSignIn;
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final response = await googleSignIn.signIn();
      return response;
    } catch (e) {
      log(e.toString());
      return Future.error('signIn: $e');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await googleSignIn.signInSilently();
    } catch (e) {
      log(e.toString());
      return Future.error('signInSilently: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      log(e.toString());
      return Future.error('signOut: $e');
    }
  }

  Future<bool> isLogged() async {
    return await googleSignIn.isSignedIn();
  }

  Future<String?> getAccessToken() async {
    try {
      final account = await googleSignIn.signInSilently();
      final auth = await account?.authentication;
      return auth?.accessToken;
    } catch (error) {
      log('Error: $error');
      return Future.error('getAccessToken: $error');
    }
  }
}
