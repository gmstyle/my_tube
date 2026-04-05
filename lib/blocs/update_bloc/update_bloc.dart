import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/update.dart';
import 'package:my_tube/respositories/update_repository.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    emit(const UpdateState.checking());
    try {
      final currentReleaseVersion = await _getAppVersion();
      final update = await updateRepository.checkForUpdate();
      final cleanVersion = updateRepository.updateProvider
          .cleanVersionString(update.releaseVersion);
      // If the current release version is minor than the latest release version
      var result = _compareSemanticVersion(currentReleaseVersion, cleanVersion);
      if (result < 0) {
        emit(UpdateState.updateAvailable(update));
      } else {
        emit(const UpdateState.noUpdateAvailable());
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

  // Compares two semantic version strings (e.g. "1.9.9" vs "1.9.10").
  // Returns negative if v1 < v2, 0 if equal, positive if v1 > v2.
  int _compareSemanticVersion(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final length =
        parts1.length > parts2.length ? parts1.length : parts2.length;
    for (var i = 0; i < length; i++) {
      final a = i < parts1.length ? parts1[i] : 0;
      final b = i < parts2.length ? parts2[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }
}
