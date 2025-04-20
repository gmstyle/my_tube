import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_tube/models/video_category_mt.dart';
import 'package:my_tube/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static String getMusicVideoCategoryId(dynamic categories) {
    final categoriesMT = categories
        .map((category) => VideoCategoryMT.fromJson(category))
        .toList();
    return categoriesMT.firstWhere((element) => element.title == 'Music').id;
  }

  static int? parseDurationStringToMilliseconds(String? isoFormatDuration) {
    if (isoFormatDuration != null) {
      RegExp regExp = RegExp(r"PT(\d+H)?(\d+M)?(\d+S)?");
      final match = regExp.firstMatch(isoFormatDuration);

      if (match != null) {
        int hours = match.group(1) != null
            ? int.parse(match.group(1)!.replaceAll("H", ""))
            : 0;
        int minutes = match.group(2) != null
            ? int.parse(match.group(2)!.replaceAll("M", ""))
            : 0;
        int seconds = match.group(3) != null
            ? int.parse(match.group(3)!.replaceAll("S", ""))
            : 0;

        return ((hours * 60 * 60) + (minutes * 60) + seconds) * 1000;
      }
    }

    return null;
  }

  //format int to 000.000.000
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
  }

  static String formatDuration(Duration? duration) {
    if (duration == null) {
      return '--:--';
    }

    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final hours = duration.inHours;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    final hoursStr = hours.toString().padLeft(1, '0');

    if (hours > 0) {
      return '$hoursStr:$minutesStr:$secondsStr';
    }

    return '$minutesStr:$secondsStr';
  }

  static Locale getLocaleFromCountryCode(String countryCode) {
    final langCode = countryToLanguage[countryCode];
    if (langCode != null) {
      return Locale(langCode, countryCode);
    } else {
      return const Locale('en', 'US');
    }
  }

  static checkIfStringIsOnlyNumeric(String string) {
    return int.tryParse(string) != null;
  }

  // request permission to save file into the Downloads system folder
  static Future<bool> checkAndRequestStoragePermissions() async {
    if (await Permission.audio.status.isDenied &&
        await Permission.storage.status.isDenied) {
      await [Permission.audio, Permission.storage].request();
      await Permission.manageExternalStorage.request();
      if (await Permission.audio.status.isDenied &&
          await Permission.storage.status.isDenied &&
          await Permission.manageExternalStorage.isDenied) {
        await openAppSettings();
      }
    }

    return await Permission.storage.isGranted ||
        await Permission.audio.isGranted ||
        await Permission.manageExternalStorage.isGranted;
  }

  // request permissions to install packages
  static Future<bool> checkAndRequestInstallPackagesPermissions() async {
    if (await Permission.requestInstallPackages.isDenied) {
      await Permission.requestInstallPackages.request();
      if (await Permission.requestInstallPackages.isDenied) {
        await openAppSettings();
      }
    }

    return await Permission.requestInstallPackages.isGranted;
  }

  // request permissions to show local notifications
  static Future<bool> checkAndRequestNotificationPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
      if (await Permission.notification.isDenied) {
        await openAppSettings();
      }
    }

    return await Permission.notification.isGranted;
  }

  static String normalizeFileName(String fileName) {
    // remove special characters
    fileName = fileName
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(' ', '_');

    return fileName;
  }

  static Widget buildImage(String? base64Image, BuildContext context) {
    final Uint8List? bytes =
        base64Image != null ? base64Decode(base64Image) : null;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
      );
    } else {
      // show a placeholder image
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          height: MediaQuery.of(context).size.height * 0.09,
          width: MediaQuery.of(context).size.width * 0.2,
        ),
      );
    }
  }
}
