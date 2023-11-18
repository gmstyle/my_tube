import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_tube/models/resource_mt.dart';

class QueueRepository {
  final queueBox = Hive.box<ResourceMT>('queue');

  List<ResourceMT> get queue => queueBox.values.toList();

  ValueListenable<Box<ResourceMT>> get queueListenable => queueBox.listenable();

  Future<void> save(ResourceMT video) async {
    final videoWithAddedAt = video.copyWith(addedAt: DateTime.now());
    await queueBox.put(video.id, videoWithAddedAt);
  }

  Future<void> saveAll(List<ResourceMT> videos) async {
    await queueBox.putAll(
        {for (var e in videos) e.id: e.copyWith(addedAt: DateTime.now())});
  }

  Future<void> remove(ResourceMT video) async {
    await queueBox.delete(video.id);
  }

  Future<void> clear() async {
    await queueBox.clear();
  }

  Future<bool> contains(String? id) async {
    return queueBox.keys.contains(id);
  }
}
