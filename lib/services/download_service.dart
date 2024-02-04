import 'dart:io';

import 'package:my_tube/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  const DownloadService();

  Future<void> downloadFile(String videoId, String fileName,
      {bool isAudioOnly = false}) async {
    // ask for permissions to save file into the Downloads system folder
    await Utils.requestPermission();
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      StreamInfo? streamInfo;
      String? fileExtension;
      if (isAudioOnly) {
        streamInfo = manifest.audioOnly.withHighestBitrate();
        fileExtension = 'm4a';
      } else {
        streamInfo = manifest.muxed.bestQuality;
        fileExtension = 'mp4';
      }

      final stream = yt.videos.streamsClient.get(streamInfo);
      final directory = await getDownloadsDirectory();
      final path = '${directory!.path}/$fileName.$fileExtension';
      final file = File(path);
      final fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
    } on Exception catch (e) {
      throw Exception('DownloadError: $e');
    } finally {
      yt.close();
    }
  }
}
