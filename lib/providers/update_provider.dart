import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_tube/utils/constants.dart';

class UpdateProvider {
  Future<String> getLatestReleaseVersion() async {
    try {
      final headers = {githubApiAcceptHeaderKey: githubApiAcceptHeaderValue};
      final response = await http.get(Uri.parse(githubLatestReleaseApiUrl),
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
    String cleanVersion = cleanVersionString(releaseVersion);

    final url =
        '$githubReleaseDownloadUrlPrefix/$releaseVersion/$releaseApkFilePrefix$cleanVersion$releaseApkFileExtension';
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

  String cleanVersionString(String releaseVersion) {
    String cleanVersion = releaseVersion;

    // Rimuovi il prefisso 'v' se presente
    if (cleanVersion.startsWith('v')) {
      cleanVersion = cleanVersion.substring(1);
    }

    // Rimuovi il build number se presente (tutto dopo il '+')
    if (cleanVersion.contains('+')) {
      cleanVersion = cleanVersion.split('+')[0];
    }
    return cleanVersion;
  }
}
