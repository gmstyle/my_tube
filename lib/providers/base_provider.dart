import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class BaseProvider {
  static GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      YouTubeApi.youtubeReadonlyScope,
      YouTubeApi.youtubeScope,
      YouTubeApi.youtubepartnerScope
    ],
  );

  static YoutubeExplode youtubeExplode = YoutubeExplode();
}
