part of 'music_tab_bloc.dart';

sealed class MusicTabEvent extends Equatable {
  const MusicTabEvent();

  @override
  List<Object> get props => [];
}

class GetMusicTabContent extends MusicTabEvent {
  const GetMusicTabContent();
}
