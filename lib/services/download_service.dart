import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  const DownloadService();

  Future<void> download(
      {required ResourceMT video,
      required BuildContext context,
      required bool isAudioOnly}) async {
    // ask for permissions to save file into the Downloads system folder
    final permissionsGranted = await Utils.checkAndRequestPermissions();
    if (!permissionsGranted) {
      return;
    }
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    final receivePort = ReceivePort();

    final args = {
      'videoId': video.id,
      'fileName': video.title,
      'isAudioOnly': isAudioOnly,
      'sendPort': receivePort.sendPort,
      'rootIsolateToken': rootIsolateToken,
    };

    Isolate.spawn(
      _downloadFileIsolate,
      args,
    );

    context.pop();
    _showSnackbar(receivePort, context, video.title!);
  }

  void _downloadFileIsolate(Map<String, dynamic> args) async {
    final sendPort = args['sendPort'] as SendPort;
    final videoId = args['videoId'] as String;
    final fileName = args['fileName'] as String;
    final rootIsolateToken = args['rootIsolateToken'] as RootIsolateToken;
    final isAudioOnly = args['isAudioOnly'] as bool;

    final stream = _downloadFileStream(videoId, fileName, rootIsolateToken,
        isAudioOnly: isAudioOnly);
    await for (final progress in stream) {
      sendPort.send(progress);
    }
  }

  Stream<double> _downloadFileStream(
      String videoId, String fileName, RootIsolateToken rootIsolateToken,
      {bool isAudioOnly = false}) async* {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      StreamInfo? streamInfo;
      String fileExtension;
      if (isAudioOnly) {
        streamInfo = manifest.audioOnly.withHighestBitrate();
        fileExtension = 'm4a';
      } else {
        streamInfo = manifest.muxed.bestQuality;
        fileExtension = 'mp4';
      }

      final stream = yt.videos.streamsClient.get(streamInfo);
      final path = await _getDownloadsPath(fileName, fileExtension);
      if (path == null) {
        throw Exception('Could not find the downloads directory');
      }
      final file = File(path);
      final fileStream = file.openWrite();

      int receivedBytes = 0;
      final totalBytes = streamInfo.size;

      await for (final data in stream) {
        fileStream.add(data);
        receivedBytes += data.length;
        yield receivedBytes / totalBytes.totalBytes;
      }

      await fileStream.flush();
      await fileStream.close();
    } on Exception catch (e) {
      throw Exception('DownloadError: $e');
    } finally {
      yt.close();
    }
  }

  void _showSnackbar(
    ReceivePort receivePort,
    BuildContext context,
    String title,
  ) {
    // show snackbar with progress that comes from the isolate
    final snackBar = SnackBar(
      showCloseIcon: true,
      duration: const Duration(days: 1),
      content: StreamBuilder(
        stream: receivePort.asBroadcastStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Preparing to download...');
          }
          if (snapshot.hasData) {
            final progress = snapshot.data as double;
            if (progress >= 1.0) {
              Future.delayed(const Duration(seconds: 10), () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              });
              String path =
                  '/storage/emulated/0/Android/data/it.gmstyle.my_tube/files/downloads';
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text('Download complete 🎉 in $path'),
                  ),
                  IconButton(
                      onPressed: () async {
                        await OpenFile.open(path);
                      },
                      icon: Icon(
                        Icons.folder,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ))
                ],
              );
            }

            return Column(
              children: [
                Text('Downloading:$title'),
                LinearProgressIndicator(value: progress),
              ],
            );
          } else if (snapshot.hasError) {
            Future.delayed(const Duration(seconds: 5), () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            });
            return Text('Error: ${snapshot.error}');
          } else {
            return const Text('Download failed!');
          }
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String?> _getDownloadsPath(String filename, String extension) async {
    // Get the directory for the app's files
    try {
      Directory? appDir = await getDownloadsDirectory();

      if (!await appDir!.exists()) {
        await appDir.create(recursive: true);
      }

      return '${appDir.path}/${Utils.normalizeFileName(filename)}.$extension';
    } catch (e) {
      return Future.error('Error: $e: Could not get downloads directory');
    }
  }
}
