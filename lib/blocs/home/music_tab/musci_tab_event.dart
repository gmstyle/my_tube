/* part of 'music_tab_bloc.dart';

sealed class MusicTabEvent extends Equatable {
  const MusicTabEvent();

  @override
  List<Object> get props => [];
}

class GetMusicHome extends MusicTabEvent {
  const GetMusicHome();
}

class GetNextPageMusic extends MusicTabEvent {
  const GetNextPageMusic({required this.nextPageToken});

  final String nextPageToken;

  @override
  List<Object> get props => [nextPageToken];
}
 */
