part of 'subscription_bloc.dart';

enum SubscriptionStatus { loading, loaded, error }

class SubscriptionState extends Equatable {
  const SubscriptionState._({required this.status, this.error, this.response});

  final SubscriptionStatus status;
  final String? error;
  final ResponseMT? response;

  const SubscriptionState.loading()
      : this._(status: SubscriptionStatus.loading);
  const SubscriptionState.loaded({required ResponseMT response})
      : this._(
          status: SubscriptionStatus.loaded,
          response: response,
        );
  const SubscriptionState.error({required String error})
      : this._(
          status: SubscriptionStatus.error,
          error: error,
        );

  @override
  List<Object?> get props => [status, error, response];
}
