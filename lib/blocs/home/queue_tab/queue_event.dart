part of 'queue_bloc.dart';

sealed class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object> get props => [];
}

class GetQueue extends QueueEvent {}

class AddToQueue extends QueueEvent {
  final ResourceMT video;

  const AddToQueue(this.video);

  @override
  List<Object> get props => [video];
}

class RemoveFromQueue extends QueueEvent {
  final ResourceMT video;

  const RemoveFromQueue(this.video);

  @override
  List<Object> get props => [video];
}

class ClearQueue extends QueueEvent {}
