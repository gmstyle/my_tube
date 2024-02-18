import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UpdateProvider {
  Future<String> getLatestReleaseVersion() async {
    try {
      final headers = {
        'Accept': 'application/vnd.github.+json',
        HttpHeaders.authorizationHeader:
            'Bearer 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'
      };
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
    final url =
        'https://github.com/gmstyle/my_tube/releases/download/$releaseVersion/app-release-$releaseVersion.apk';
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
