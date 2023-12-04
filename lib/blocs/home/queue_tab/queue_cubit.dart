import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/respositories/youtube_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';

part 'queue_state.dart';

class QueueCubit extends Cubit<void> {
  final QueueRepository queueRepository;
  final YoutubeRepository youtubeRepository;
  final MtPlayerHandler mtPlayerHandler;
  QueueCubit(
      {required this.queueRepository,
      required this.youtubeRepository,
      required this.mtPlayerHandler})
      : super(QueueInitial());

  Future<void> addToQueue(ResourceMT video) async {
    await mtPlayerHandler.addToQueue(video);
  }

  Future<void> removeFromQueue(ResourceMT video) async {
    await mtPlayerHandler.removeFromQueue(video);
  }

  Future<void> clearQueue() async {
    await mtPlayerHandler.clearQueue();
  }
}
