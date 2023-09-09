import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_tube/providers/auth_provider.dart';

class AuthRepository {
  AuthRepository({required this.authProvider});

  final AuthProvider authProvider;

  Future<bool> isLogged() async {
    return await authProvider.isLogged();
  }

  Future<String?> getAccessToken() async {
    return await authProvider.getAccessToken();
  }

  Future<void> signOut() async {
    return await authProvider.signOut();
  }

  Future<GoogleSignInAccount?> signIn() async {
    return await authProvider.signIn();
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    return await authProvider.signInSilently();
  }
}
