import 'package:google_sign_in/google_sign_in.dart';

class BaseProvider {
  static final scopes = [
    'email',
    'https://www.googleapis.com/auth/youtube.readonly'
  ];

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);
}
