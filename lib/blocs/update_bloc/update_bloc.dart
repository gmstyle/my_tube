import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/update.dart';
import 'package:my_tube/respositories/update_repository.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_file_platform_interface/src/types/open_result.dart';

part 'update_event.dart';
part 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final UpdateRepository updateRepository;

  UpdateBloc({required this.updateRepository})
      : super(const UpdateState.initial()) {
    on<CheckForUpdate>((event, emit) async {
      await _onCheckForUpdate(event, emit);
    });

    on<InstallUpdate>((event, emit) async {
      await _onInstallUpdate(event, emit);
    });
  }

  Future<void> _onCheckForUpdate(
      CheckForUpdate event, Emitter<UpdateState> emit) async {
    try {
      final currentReleaseVersion = await _getAppVersion();
      final update = await updateRepository.checkForUpdate();
      // If the current release version is minor than the latest release version
      var result = currentReleaseVersion.compareTo(update.releaseVersion);
      if (result < 0) {
        emit(UpdateState.updateAvailable(update));
      }
    } catch (e) {
      emit(UpdateState.failure(e.toString()));
    }
  }

  Future<void> _onInstallUpdate(
      InstallUpdate event, Emitter<UpdateState> emit) async {
    emit(const UpdateState.downloading());
    try {
      // Request permission to install packages
      final permissionGranted =
          await Utils.checkAndRequestInstallPackagesPermissions();
      if (!permissionGranted) {
        emit(const UpdateState.failure('Permission not granted'));
        return;
      }
      final path =
          await updateRepository.downloadLatestRelease(event.releaseVersion);
      // Install the downloaded release
      final result = await OpenFile.open(path);
      if (result.type == ResultType.done) {
        emit(const UpdateState.downloadSuccess());
      } else {
        emit(UpdateState.failure(result.message));
      }
    } catch (e) {
      emit(UpdateState.failure(e.toString()));
    }
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }
}
