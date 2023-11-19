part of 'my_account_bloc.dart';

enum MyAccountStatus { initial, loading, loaded, error }

class MyAccountState extends Equatable {
  const MyAccountState._({
    required this.status,
    this.error,
  });

  final MyAccountStatus status;
  final String? error;

  const MyAccountState.initial() : this._(status: MyAccountStatus.initial);
  const MyAccountState.loading() : this._(status: MyAccountStatus.loading);
  const MyAccountState.loaded()
      : this._(
          status: MyAccountStatus.loaded,
        );
  const MyAccountState.error(String error)
      : this._(status: MyAccountStatus.error, error: error);

  @override
  List<Object?> get props => [status, error];
}
