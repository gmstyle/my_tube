part of 'subscription_bloc.dart';

enum SubscriptionStatus { initial, loading, success, failure }

class SubscriptionState extends Equatable {
  const SubscriptionState._({
    required this.status,
    this.error,
  });

  final SubscriptionStatus status;
  final String? error;

  const SubscriptionState.initial()
      : this._(status: SubscriptionStatus.initial);

  @override
  List<Object> get props => [];
}
