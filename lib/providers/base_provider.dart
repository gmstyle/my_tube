import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';

class BaseProvider {
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      YouTubeApi.youtubeReadonlyScope,
      YouTubeApi.youtubeScope,
      YouTubeApi.youtubepartnerScope
    ],
  );
}
