part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class GetSubscriptions extends SubscriptionEvent {
  const GetSubscriptions();

  @override
  List<Object> get props => [];
}

class GetNextPageSubscriptions extends SubscriptionEvent {
  const GetNextPageSubscriptions({required this.nextPageToken});

  final String nextPageToken;

  @override
  List<Object> get props => [nextPageToken];
}
