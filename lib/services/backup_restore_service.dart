import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../utils/utils.dart';
import '../utils/constants.dart';

class BackupRestoreService {
  /// Esporta i dati direttamente nella cartella Download/MyTube/Backups del dispositivo.
  /// Segue lo stesso pattern di DownloadService per evitare blocchi del sistema di condivisione.
  Future<String> exportData() async {
    // 1. Richiesta permessi (come in DownloadService)
    final permissionsGranted = await Utils.checkAndRequestStoragePermissions();
    if (!permissionsGranted) {
      throw Exception('Permessi di archiviazione negati');
    }

    final Map<String, dynamic> data = {
      hiveSettingsBoxName: _boxToMap(Hive.box(hiveSettingsBoxName)),
      hiveFavoriteVideosBoxName:
          _boxToMap(Hive.box<String>(hiveFavoriteVideosBoxName)),
      hiveFavoriteChannelsBoxName:
          _boxToMap(Hive.box<String>(hiveFavoriteChannelsBoxName)),
      hiveFavoritePlaylistsBoxName:
          _boxToMap(Hive.box<String>(hiveFavoritePlaylistsBoxName)),
      hiveRecentlyPlayedBoxName:
          _boxToMap(Hive.box<String>(hiveRecentlyPlayedBoxName)),
      hiveCustomPlaylistsBoxName:
          _boxToMap(Hive.box<String>(hiveCustomPlaylistsBoxName)),
    };

    final jsonString = jsonEncode(data);
    final fileName =
        'mytube_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    // 2. Definizione del percorso (come in DownloadService)
    final directory = Directory('/storage/emulated/0/Download/MyTube/Backups');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // 3. Scrittura diretta del file
    await file.writeAsString(jsonString);

    return filePath;
  }

  Future<bool> importData() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      return false; // User canceled the picker
    }

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await _importBox(hiveSettingsBoxName, data[hiveSettingsBoxName]);
    await _importBox(
        hiveFavoriteVideosBoxName, data[hiveFavoriteVideosBoxName]);
    await _importBox(
        hiveFavoriteChannelsBoxName, data[hiveFavoriteChannelsBoxName]);
    await _importBox(
        hiveFavoritePlaylistsBoxName, data[hiveFavoritePlaylistsBoxName]);
    await _importBox(
        hiveRecentlyPlayedBoxName, data[hiveRecentlyPlayedBoxName]);
    await _importBox(
        hiveCustomPlaylistsBoxName, data[hiveCustomPlaylistsBoxName]);

    return true;
  }

  Map<String, dynamic> _boxToMap(Box box) {
    return box.toMap().map((key, value) => MapEntry(key.toString(), value));
  }

  Future<void> _importBox(String boxName, dynamic data) async {
    if (data == null) return;

    final mapData = data as Map<String, dynamic>;

    if (boxName == hiveSettingsBoxName) {
      final box = Hive.box(boxName);
      await box.clear();
      for (var entry in mapData.entries) {
        await box.put(entry.key, entry.value);
      }
    } else if (boxName == hiveCustomPlaylistsBoxName) {
      final box = Hive.box<String>(boxName);
      await box.clear();
      for (var entry in mapData.entries) {
        await box.put(entry.key, entry.value.toString());
        // For custom playlists, keys are string UUIDs, values are JSON strings
      }
    } else {
      // It's a list-like box (favorites, recents)
      final box = Hive.box<String>(boxName);
      await box.clear();
      await box.addAll(mapData.values.map((v) => v.toString()));
    }
  }
}
