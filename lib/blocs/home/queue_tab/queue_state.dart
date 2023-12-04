part of 'queue_bloc.dart';

enum QueueStatus { initial, loading, success, failure }

class QueueState extends Equatable {
  const QueueState._({required this.status, this.queue, this.error});

  final QueueStatus status;
  final List<ResourceMT>? queue;
  final String? error;

  const QueueState.initial() : this._(status: QueueStatus.initial);
  const QueueState.loading() : this._(status: QueueStatus.loading);
  const QueueState.success(List<ResourceMT>? queue)
      : this._(status: QueueStatus.success, queue: queue);
  const QueueState.failure(String error)
      : this._(status: QueueStatus.failure, error: error);

  @override
  List<Object?> get props => [status, queue, error];
}
