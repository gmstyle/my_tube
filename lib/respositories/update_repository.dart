import 'dart:convert';
import 'dart:io';

import 'package:my_tube/models/update.dart';
import 'package:my_tube/providers/update_provider.dart';
import 'package:path_provider/path_provider.dart';

class UpdateRepository {
  final UpdateProvider updateProvider;

  UpdateRepository({required this.updateProvider});

  Future<Update> checkForUpdate() async {
    try {
      final response = await updateProvider.getLatestReleaseVersion();
      final jsonResponse = jsonDecode(response);
      final releaseVersion = jsonResponse['tag_name'];
      final changeLog = jsonResponse['body'];

      return Update(releaseVersion: releaseVersion, changeLog: changeLog);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<String> downloadLatestRelease(String releaseVersion) async {
    try {
      final response =
          await updateProvider.downloadLatestRelease(releaseVersion);
      // Save the response to a file
      final dir = await getDownloadsDirectory();
      final file = File('${dir?.path}/app-release-$releaseVersion.apk');
      await file.writeAsBytes(response);
      return file.path;
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
