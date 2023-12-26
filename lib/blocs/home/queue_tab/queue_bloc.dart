import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository queueRepository;
  final InnertubeRepository innertubeRepository;
  final MtPlayerHandler mtPlayerHandler;
  QueueBloc(
      {required this.queueRepository,
      required this.innertubeRepository,
      required this.mtPlayerHandler})
      : super(const QueueState.initial()) {
    // ascolto il cambiamento della coda e aggiorno lo stato
    // quando viene aggiunto o rimosso un video
    queueRepository.queueListenable.addListener(() {
      add(GetQueue());
    });

    on<GetQueue>((event, emit) async {
      await _onGetQueue(event, emit);
    });

    on<AddToQueue>((event, emit) async {
      await _onAddToQueue(event, emit);
    });

    on<RemoveFromQueue>((event, emit) async {
      await _onRemoveFromQueue(event, emit);
    });

    on<ClearQueue>((event, emit) async {
      await _onClearQueue(event, emit);
    });
  }

  Future<void> _onGetQueue(QueueEvent event, Emitter<QueueState> emit) async {
    emit(const QueueState.loading());
    final videos = <ResourceMT>[];
    for (final id in queueRepository.videoIds) {
      final video =
          await innertubeRepository.getVideo(id, withStreamUrl: false);
      videos.add(video);
    }
    emit(QueueState.success(videos));
  }

  Future<void> _onAddToQueue(QueueEvent event, Emitter<QueueState> emit) async {
    final video = (event as AddToQueue).video;
    await mtPlayerHandler.addToQueue(video);
    final queue = queueRepository.queue;
    emit(QueueState.success(queue));
  }

  Future<void> _onRemoveFromQueue(
      QueueEvent event, Emitter<QueueState> emit) async {
    final video = (event as RemoveFromQueue).video;
    await mtPlayerHandler.removeFromQueue(video);
    final queue = queueRepository.queue;
    emit(QueueState.success(queue));
  }

  Future<void> _onClearQueue(QueueEvent event, Emitter<QueueState> emit) async {
    await mtPlayerHandler.clearQueue();
    final queue = queueRepository.queue;
    emit(QueueState.success(queue));
  }
}
