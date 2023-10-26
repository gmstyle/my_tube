import 'package:my_tube/models/video_category_mt.dart';

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
}
