part of 'update_bloc.dart';

enum UpdateStatus {
  initial,
  downloading,
  updateAvailable,
  downloadSuccess,
  failure
}

class UpdateState extends Equatable {
  const UpdateState._({required this.status, this.update, this.errorMessage});

  final UpdateStatus status;
  final Update? update;
  final String? errorMessage;

  const UpdateState.initial() : this._(status: UpdateStatus.initial);
  const UpdateState.downloading() : this._(status: UpdateStatus.downloading);
  const UpdateState.updateAvailable(Update update)
      : this._(status: UpdateStatus.updateAvailable, update: update);
  const UpdateState.downloadSuccess()
      : this._(
          status: UpdateStatus.downloadSuccess,
        );
  const UpdateState.failure(String errorMessage)
      : this._(status: UpdateStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, update, errorMessage];
}
