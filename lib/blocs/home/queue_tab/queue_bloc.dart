import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository queueRepository;
  final MtPlayerHandler mtPlayerHandler;
  QueueBloc({required this.queueRepository, required this.mtPlayerHandler})
      : super(const QueueState.initial()) {
    // ascolto il cambiamento della coda e aggiorno lo stato
    // quando viene aggiunto o rimosso un video
    queueRepository.queueListenable.addListener(() {
      add(GetQueue());
    });

    on<GetQueue>((event, emit) {
      _onGetQueue(event, emit);
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

  void _onGetQueue(QueueEvent event, Emitter<QueueState> emit) {
    emit(const QueueState.loading());
    final queue = queueRepository.queue;
    emit(QueueState.success(queue));
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
