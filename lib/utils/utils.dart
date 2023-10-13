import 'package:my_tube/models/video_category_mt.dart';

class Utils {
  static String getMusicVideoCategoryId(dynamic categories) {
    final categoriesMT = categories
        .map((category) => VideoCategoryMT.fromJson(category))
        .toList();
    return categoriesMT.firstWhere((element) => element.title == 'Music').id;
  }
}
