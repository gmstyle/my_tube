import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';

class FavoritesRepository {
  final favoritesBox = Hive.box<ResourceMT>('favorites');

  List<ResourceMT> get favorites =>
      favoritesBox.values.toList().reversed.toList();

  List<String> get videoIds => favorites.map((e) => e.id!).toList();

  ValueListenable<Box<ResourceMT>> get favoritesListenable =>
      favoritesBox.listenable();

  Future<void> add(ResourceMT video) async {
    await favoritesBox.add(video);
  }

  Future<void> addAll(List<ResourceMT> videos) async {
    await favoritesBox.addAll(videos);
  }

  Future<void> remove(ResourceMT video) async {
    final index = favorites.indexWhere((element) => element.id == video.id);
    await favoritesBox.deleteAt(index);
  }

  Future<void> clear() async {
    await favoritesBox.clear();
  }

  Future<bool> contains(String? id) async {
    return favoritesBox.keys.contains(id);
  }
}
