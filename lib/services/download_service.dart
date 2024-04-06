import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  const DownloadService();

  Future<void> download(
      {required List<ResourceMT> videos,
      required BuildContext context,
      String? destinationDir,
      bool isAudioOnly = false}) async {
    // ask for permissions to save file into the Downloads system folder
    final permissionsGranted = await Utils.checkAndRequestStoragePermissions();
    if (!permissionsGranted) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    final receivePort = ReceivePort();

    // crea una nuova lista di video da passare all'isolato ma per ogni video prendi solo l'id e il titolo
    final List<Map<String, String>> newVideos = videos.map((video) {
      return {
        'id': video.id!,
        'title': video.title!,
      };
    }).toList();

    final args = {
      'videos': newVideos,
      'destinationDir': destinationDir,
      'isAudioOnly': isAudioOnly,
      'sendPort': receivePort.sendPort,
      'rootIsolateToken': rootIsolateToken,
    };

    Isolate.spawn(
      _downloadFilesIsolate,
      args,
    );

    _showSnackbar(receivePort, context, destinationDir ?? videos.first.title!);
  }

  void _downloadFilesIsolate(Map<String, dynamic> args) async {
    final sendPort = args['sendPort'] as SendPort;
    final videos = args['videos'] as List<Map<String, String>>;
    final destinationDir = args['destinationDir'] as String?;
    final rootIsolateToken = args['rootIsolateToken'] as RootIsolateToken;
    final isAudioOnly = args['isAudioOnly'] as bool;

    int totalVideos = videos.length;
    List<double> progressList = List.filled(totalVideos, 0.0);

    // Create a queue of downloads
    Queue<int> downloadQueue =
        Queue<int>.from(Iterable<int>.generate(totalVideos));

    // Function to start a download
    Future<void> startDownload(int i) async {
      final video = videos[i];
      final stream = _downloadFileStream(video['id']!, video['title']!,
          destinationDir, rootIsolateToken, totalVideos,
          isAudioOnly: isAudioOnly);
      await for (final progress in stream) {
        progressList[i] = progress;
        double totalProgress =
            progressList.reduce((a, b) => a + b) / totalVideos;
        sendPort.send(totalProgress);
      }
      // Start the next download when this one is finished
      if (downloadQueue.isNotEmpty) {
        startDownload(downloadQueue.removeFirst());
      }
    }

    // Start the first download
    startDownload(downloadQueue.removeFirst());
  }

  Stream<double> _downloadFileStream(
      String videoId,
      String fileName,
      String? destinationDir,
      RootIsolateToken rootIsolateToken,
      int totalVideos,
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
      final path =
          await _getDownloadsPath(fileName, fileExtension, destinationDir);
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
    //Close the previous snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text('Download complete 🎉'),
                  ),
                  IconButton(
                      onPressed: () async {
                        await OpenFile.open('/storage/emulated/0/Download');
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
                Text('Downloading: $title'),
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

  Future<String?> _getDownloadsPath(
      String filename, String extension, String? destinationDir) async {
    // Get the directory for the app's files
    try {
      Directory appDir = Directory('/storage/emulated/0/Download/MyTube');

      // If there are multiple videos, create a folder with the playlist name
      if (destinationDir != null) {
        appDir = Directory('${appDir.path}/$destinationDir');
      }

      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }

      return '${appDir.path}/${Utils.normalizeFileName(filename)}.$extension';
    } catch (e) {
      return Future.error('Error: $e: Could not get downloads directory');
    }
  }
}
