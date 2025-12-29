import 'dart:async';
import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Service per il caricamento massivo di video metadata in un isolato separato
class BulkVideoLoader {
  /// Carica i metadata di una lista di video in un isolato separato
  ///
  /// [videoIds] - Lista di ID video da caricare
  /// [onProgress] - Callback per notificare il progresso (current, total)
  /// [onItemLoaded] - Callback per ogni video caricato (MediaItem)
  ///
  /// Returns: Lista di MediaItem con metadata caricati (senza streamUrl)
  static Future<List<MediaItem>> loadVideosInIsolate({
    required List<String> videoIds,
    Function(int current, int total)? onProgress,
    Function(MediaItem item)? onItemLoaded,
  }) async {
    if (videoIds.isEmpty) return [];

    final receivePort = ReceivePort();
    final completer = Completer<List<MediaItem>>();
    final loadedItems = <MediaItem>[];

    try {
      // Spawn isolate
      await Isolate.spawn(
        _loadVideosIsolate,
        {
          'videoIds': videoIds,
          'sendPort': receivePort.sendPort,
        },
      );

      // Listen for messages from isolate
      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          if (message.containsKey('progress')) {
            // Progress update
            final current = message['progress'] as int;
            final total = message['total'] as int;
            onProgress?.call(current, total);
          } else if (message.containsKey('item')) {
            // Single item loaded
            final itemData = message['item'] as Map<String, dynamic>;
            final mediaItem = _deserializeMediaItem(itemData);
            loadedItems.add(mediaItem);
            onItemLoaded?.call(mediaItem);
          } else if (message.containsKey('done')) {
            // All done
            completer.complete(loadedItems);
            receivePort.close();
          } else if (message.containsKey('error')) {
            // Error occurred
            completer.completeError(message['error']);
            receivePort.close();
          }
        }
      });

      return await completer.future;
    } catch (e) {
      receivePort.close();
      rethrow;
    }
  }

  /// Isolate worker function - carica video metadata in parallelo
  static void _loadVideosIsolate(Map<String, dynamic> args) async {
    final videoIds = args['videoIds'] as List<String>;
    final sendPort = args['sendPort'] as SendPort;

    try {
      final yt = YoutubeExplode();
      final batchSize = 10; // Carica 10 video alla volta in parallelo

      for (int batchStart = 0;
          batchStart < videoIds.length;
          batchStart += batchSize) {
        final batchEnd = (batchStart + batchSize < videoIds.length)
            ? batchStart + batchSize
            : videoIds.length;
        final batchIds = videoIds.sublist(batchStart, batchEnd);

        // Carica batch di video in parallelo
        final futures = batchIds.map((id) async {
          try {
            final video = await yt.videos.get(id);
            return {'success': true, 'video': video};
          } catch (e) {
            // Ignora video che falliscono e continua
            return {'success': false, 'id': id, 'error': e.toString()};
          }
        }).toList();

        final results = await Future.wait(futures);

        // Invia i risultati uno per uno
        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          if (result['success'] == true) {
            final video = result['video'] as Video;
            final mediaItem = _createMediaItemFromVideo(video);
            final serialized = _serializeMediaItem(mediaItem);
            sendPort.send({
              'item': serialized,
            });
          }

          // Invia il progresso
          final currentProgress = batchStart + i + 1;
          sendPort.send({
            'progress': currentProgress,
            'total': videoIds.length,
          });
        }
      }

      yt.close();
      sendPort.send({'done': true});
    } catch (e) {
      sendPort.send({'error': e.toString()});
    }
  }

  /// Crea un MediaItem da un oggetto Video (senza streamUrl)
  static MediaItem _createMediaItemFromVideo(Video video) {
    return MediaItem(
      id: video.id.value,
      title: video.title,
      album: video.musicData.isNotEmpty ? video.musicData.first.album : null,
      artUri: Uri.parse(video.thumbnails.highResUrl),
      duration: video.duration,
      extras: {
        'streamUrl': null, // Stream URL sarà caricato quando necessario
        'description': video.description,
      },
    );
  }

  /// Serializza un MediaItem in una Map per passarlo tra isolati
  static Map<String, dynamic> _serializeMediaItem(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'album': item.album,
      'durationMs': item.duration?.inMilliseconds,
      'artUri': item.artUri?.toString(),
      'extras': item.extras,
    };
  }

  /// Deserializza una Map in un MediaItem
  static MediaItem _deserializeMediaItem(Map<String, dynamic> data) {
    return MediaItem(
      id: data['id'] as String,
      title: data['title'] as String,
      album: data['album'] as String?,
      duration: data['durationMs'] != null
          ? Duration(milliseconds: data['durationMs'] as int)
          : null,
      artUri:
          data['artUri'] != null ? Uri.parse(data['artUri'] as String) : null,
      extras: data['extras'] as Map<String, dynamic>?,
    );
  }
}
