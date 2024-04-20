import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/local_notification_helper.dart.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  Isolate? _isolate;
  StreamSubscription<void>? _cancelSubscription;

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

    //nask for permissions to show local notifications
    final notificationPermissionsGranted =
        await Utils.checkAndRequestNotificationPermissions();
    if (!notificationPermissionsGranted) {
      return;
    }

    if (destinationDir != null) {
      destinationDir = Utils.normalizeFileName(destinationDir);
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

    _isolate = await Isolate.spawn(
      _downloadFilesIsolate,
      args,
    );

    // Ascolta gli eventi di annullamento e annulla il download quando viene ricevuto un evento
    _cancelSubscription =
        LocalNotificationHelper.onCancelDownload.listen((_) async {
      if (_isolate != null) {
        _isolate?.kill(priority: Isolate.immediate);
        _isolate = null;

        // elimino i file parzialmente scaricati
        // Aspetta che tutti i download siano completati
        await _deletePartialFile(destinationDir);
      }
    });

    //_showSnackbar(receivePort, context, destinationDir ?? videos.first.title!);
    _showNotification(receivePort, context,
        destinationDir ?? videos.first.title!, destinationDir);
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
    try {
      await for (final data in stream) {
        fileStream.add(data);
        receivedBytes += data.length;
        yield receivedBytes / totalBytes.totalBytes;
      }
    } on Exception catch (e) {
      throw Exception('DownloadError: $e');
    } finally {
      await fileStream.flush();
      await fileStream.close();
      yt.close();
    }
  }

  void _showNotification(ReceivePort receivePort, BuildContext context,
      String title, String? destinationDir) {
    StreamSubscription<double>? subscription;
    int lastUpdateMillis = 0;
    subscription = receivePort.cast<double>().listen((progress) {
      int intProgress = (progress * 100).toInt();
      int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
      if (currentTimeMillis - lastUpdateMillis > 500 || intProgress >= 100) {
        lastUpdateMillis = currentTimeMillis;
        if (intProgress >= 100) {
          subscription?.cancel();
          LocalNotificationHelper.showDownloadNotification(
              title: 'Download complete',
              body: 'Download of $title is complete',
              progress: intProgress,
              payload: destinationDir);

          _isolate?.kill();
          _isolate = null;
        } else {
          if (kDebugMode) {
            print('Progress: $intProgress');
          }
          LocalNotificationHelper.showDownloadNotification(
            title: 'Downloading',
            body: 'Downloading $title',
            progress: intProgress,
          );
        }
      }
    }, onError: (error, stacktrace) {
      subscription?.cancel();
      _cancelSubscription?.cancel();
      LocalNotificationHelper.showDownloadNotification(
        title: 'Download failed',
        body: 'Download of $title failed',
        progress: 0,
      );

      _isolate?.kill();
      _isolate = null;
    }, onDone: () {
      subscription?.cancel();
      _cancelSubscription?.cancel();
      _isolate?.kill();
      _isolate = null;
    });
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

  Future<void> _deletePartialFile(String? destinationDir) async {
    final directory = Directory('/storage/emulated/0/Download/MyTube');

    // Elimina la cartella se esiste
    if (destinationDir != null) {
      final dir = Directory('${directory.path}/$destinationDir');
      var dirExists = await dir.exists();
      if (dirExists) {
        try {
          await dir.delete(recursive: true);
        } on FileSystemException catch (e) {
          if (e.osError?.errorCode == 2) {
            // No such file or directory
            print('Directory does not exist: ${dir.path}');
          } else {
            rethrow;
          }
        }
      }
    }
  }
}
