import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UpdateProvider {
  Future<String> getLatestReleaseVersion() async {
    try {
      final headers = {'Accept': 'application/vnd.github.+json'};
      final response = await http.get(
          Uri.parse(
              'https://api.github.com/repos/gmstyle/my_tube/releases/latest'),
          headers: headers);
      if (response.statusCode != 200) {
        return Future.error('Error: ${response.statusCode}');
      }
      return response.body;
    } catch (error) {
      return Future.error('Error: $error');
    }
  }

  Future<Uint8List> downloadLatestRelease(String releaseVersion) async {
    // Estrai solo la versione dal tag (rimuovi 'v' e build number se presenti)
    // Esempi: "v1.5.7+1" -> "1.5.7", "1.5.6" -> "1.5.6"
    String cleanVersion = releaseVersion;

    // Rimuovi il prefisso 'v' se presente
    if (cleanVersion.startsWith('v')) {
      cleanVersion = cleanVersion.substring(1);
    }

    // Rimuovi il build number se presente (tutto dopo il '+')
    if (cleanVersion.contains('+')) {
      cleanVersion = cleanVersion.split('+')[0];
    }

    final url =
        'https://github.com/gmstyle/my_tube/releases/download/$cleanVersion/app-release-$cleanVersion.apk';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return Future.error('Error: ${response.statusCode}');
      }
      return response.bodyBytes;
    } catch (error) {
      return Future.error('Error: $error');
    }
  }
}
