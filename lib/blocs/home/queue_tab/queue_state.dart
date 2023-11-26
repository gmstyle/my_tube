part of 'queue_cubit.dart';

sealed class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object> get props => [];
}

final class QueueInitial extends QueueState {}
