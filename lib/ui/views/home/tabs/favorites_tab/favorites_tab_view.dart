import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/layouts/favorites_mobile_layout.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/layouts/favorites_tablet_layout.dart';

class FavoritesTabView extends StatefulWidget {
  const FavoritesTabView({super.key});

  @override
  State<FavoritesTabView> createState() => _FavoritesTabViewState();
}

class _FavoritesTabViewState extends State<FavoritesTabView> {
  FavoriteCategory _active = FavoriteCategory.videos;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesVideoBloc>().add(const GetFavorites());
    context.read<FavoritesChannelBloc>().add(const GetFavoritesChannel());
    context.read<FavoritesPlaylistBloc>().add(const GetFavoritesPlaylist());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      mobile: (_) => FavoritesMobileLayout(
        active: _active,
        onSelectCategory: (cat) => setState(() => _active = cat),
      ),
      tablet: (_) => FavoritesTabletLayout(
        active: _active,
        onSelectCategory: (cat) => setState(() => _active = cat),
      ),
    );
  }
}

enum FavoriteCategory { videos, channels, playlists, myPlaylists }
