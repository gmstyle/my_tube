import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';

class FavoritesRepository {
  final queueBox = Hive.box<ResourceMT>('favorites');

  List<ResourceMT> get favorites => queueBox.values.toList();

  List<String> get videoIds => favorites.map((e) => e.id!).toList();

  ValueListenable<Box<ResourceMT>> get queueListenable => queueBox.listenable();

  Future<void> save(ResourceMT video) async {
    await queueBox.add(video);
  }

  Future<void> saveAll(List<ResourceMT> videos) async {
    await queueBox.addAll(videos);
  }

  Future<void> remove(ResourceMT video) async {
    final index = favorites.indexWhere((element) => element.id == video.id);
    await queueBox.deleteAt(index);
  }

  Future<void> clear() async {
    await queueBox.clear();
  }

  Future<bool> contains(String? id) async {
    return queueBox.keys.contains(id);
  }
}
