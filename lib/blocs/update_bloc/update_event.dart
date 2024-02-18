part of 'update_bloc.dart';

sealed class UpdateEvent extends Equatable {
  const UpdateEvent();

  @override
  List<Object> get props => [];
}

class CheckForUpdate extends UpdateEvent {
  const CheckForUpdate();
}

class InstallUpdate extends UpdateEvent {
  final String releaseVersion;
  const InstallUpdate({required this.releaseVersion});

  @override
  List<Object> get props => [releaseVersion];
}
