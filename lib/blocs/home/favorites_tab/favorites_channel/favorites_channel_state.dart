part of 'favorites_channel_bloc.dart';

enum FavoritesChannelStatus { initial, loading, success, failure }

class FavoritesChannelState extends Equatable {
  const FavoritesChannelState._(
      {required this.status, this.channels, this.error});

  final FavoritesChannelStatus status;
  final List<ChannelTile>? channels;
  final String? error;

  const FavoritesChannelState.initial()
      : this._(status: FavoritesChannelStatus.initial);

  const FavoritesChannelState.loading()
      : this._(status: FavoritesChannelStatus.loading);

  const FavoritesChannelState.success(List<ChannelTile>? channels)
      : this._(status: FavoritesChannelStatus.success, channels: channels);

  const FavoritesChannelState.failure(String error)
      : this._(status: FavoritesChannelStatus.failure, error: error);

  @override
  List<Object?> get props => [status, channels, error];
}
