import 'package:equatable/equatable.dart';

enum BackupRestoreStatus { initial, loading, success, failure }

class BackupRestoreState extends Equatable {
  final BackupRestoreStatus status;
  final String? errorMessage;
  final String? successMessage;

  const BackupRestoreState({
    this.status = BackupRestoreStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  BackupRestoreState copyWith({
    BackupRestoreStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return BackupRestoreState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}
