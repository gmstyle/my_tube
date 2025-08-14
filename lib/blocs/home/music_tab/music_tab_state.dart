/* part of 'music_tab_bloc.dart';

enum FavoritesStatus { initial, loading, success, error }

class MusicTabState extends Equatable {
  const MusicTabState._({
    required this.status,
    this.error,
    this.response,
  });

  final FavoritesStatus status;
  final String? error;
  final MusicHomeMT? response;

  const MusicTabState.loading() : this._(status: FavoritesStatus.loading);
  const MusicTabState.loaded({required MusicHomeMT response})
      : this._(
          status: FavoritesStatus.success,
          response: response,
        );
  const MusicTabState.error({required String error})
      : this._(status: FavoritesStatus.error, error: error);

  @override
  List<Object?> get props => [status, error, response];
}
 */
