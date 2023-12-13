import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class BaseProvider {
  static GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      YouTubeApi.youtubeReadonlyScope,
      YouTubeApi.youtubeScope,
      YouTubeApi.youtubepartnerScope
    ],
  );

  static YoutubeExplode youtubeExplode = YoutubeExplode();

  static Future<String?> getIpAdress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      return response.body;
    } catch (error) {
      return Future.error('Error: $error');
    }
  }
}
