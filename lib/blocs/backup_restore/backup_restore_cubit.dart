import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/backup_restore_service.dart';
import 'backup_restore_state.dart';

class BackupRestoreCubit extends Cubit<BackupRestoreState> {
  final BackupRestoreService _service;

  BackupRestoreCubit(this._service) : super(const BackupRestoreState());

  Future<void> exportData() async {
    emit(state.copyWith(status: BackupRestoreStatus.loading));
    try {
      final savedPath = await _service.exportData();
      emit(state.copyWith(
          status: BackupRestoreStatus.success,
          successMessage: 'Backup salvato con successo in:\n$savedPath'));
      emit(state.copyWith(
          status: BackupRestoreStatus.initial, successMessage: null));
    } catch (e) {
      emit(state.copyWith(
          status: BackupRestoreStatus.failure, errorMessage: e.toString()));
      emit(state.copyWith(
          status: BackupRestoreStatus.initial, errorMessage: null));
    }
  }

  Future<void> importData() async {
    emit(state.copyWith(status: BackupRestoreStatus.loading));
    try {
      final success = await _service.importData();
      if (success) {
        emit(state.copyWith(status: BackupRestoreStatus.success, successMessage: 'Import successful. Please restart the app for all changes to take effect.'));
        emit(state.copyWith(status: BackupRestoreStatus.initial, successMessage: null));
      } else {
        emit(state.copyWith(status: BackupRestoreStatus.initial)); // User cancelled picker
      }
    } catch (e) {
      emit(state.copyWith(status: BackupRestoreStatus.failure, errorMessage: 'Failed to import: $e'));
      emit(state.copyWith(status: BackupRestoreStatus.initial, errorMessage: null));
    }
  }
}
