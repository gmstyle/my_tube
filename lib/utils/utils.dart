import 'package:device_info_plus/device_info_plus.dart';
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

  static String fornmatDuration(Duration? duration) {
    if (duration == null) {
      return '--:--';
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final hours = duration.inHours;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    final hoursStr = hours.toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
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
  static Future<void> requestPermission() async {
    // if android sdk is 30 or higher
    if (await _getAndroidSdkInt() <= 30) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw Exception('Permission denied: cannot save file');
        }
      }
    }

    /* final status = await Permission.manageExternalStorage.status;
      if (status.isGranted) {
        return;
      } else {
        final result = await Permission.manageExternalStorage.request();
        if (result.isGranted) {
          return;
        }
      } */
  }

  static _getAndroidSdkInt() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final androidSdkInt = androidInfo.version.sdkInt;
    return androidSdkInt;
  }
}
