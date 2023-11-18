part of 'my_account_bloc.dart';

enum MyAccountStatus { initial, loading, loaded, error }

class MyAccountState extends Equatable {
  const MyAccountState._({
    required this.status,
    this.error,
    this.queue,
  });

  final MyAccountStatus status;
  final String? error;
  final List<ResourceMT>? queue;

  const MyAccountState.initial() : this._(status: MyAccountStatus.initial);
  const MyAccountState.loading() : this._(status: MyAccountStatus.loading);
  const MyAccountState.loaded(List<ResourceMT> queue)
      : this._(status: MyAccountStatus.loaded, queue: queue);
  const MyAccountState.error(String error)
      : this._(status: MyAccountStatus.error, error: error);

  @override
  List<Object?> get props => [status, error, queue];
}
