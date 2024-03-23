part of 'favorites_channel_bloc.dart';

sealed class FavoritesChannelEvent extends Equatable {
  const FavoritesChannelEvent();

  @override
  List<Object> get props => [];
}

class GetFavoritesChannel extends FavoritesChannelEvent {
  const GetFavoritesChannel();
}

class AddToFavoritesChannel extends FavoritesChannelEvent {
  final ResourceMT channel;

  const AddToFavoritesChannel(this.channel);

  @override
  List<Object> get props => [channel];
}

class RemoveFromFavoritesChannel extends FavoritesChannelEvent {
  final String id;

  const RemoveFromFavoritesChannel(this.id);

  @override
  List<Object> get props => [id];
}

class ClearFavoritesChannel extends FavoritesChannelEvent {
  const ClearFavoritesChannel();
}
