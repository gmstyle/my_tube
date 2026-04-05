import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/router/app_router.dart';

/// Centralised navigation helper for shared secondary routes (Channel, Playlist,
/// CustomPlaylist, Queue).
///
/// These routes are nested under every tab branch of the StatefulShellRoute, so
/// navigation must be branch-aware. This helper reads the current router
/// location and prefixes the target path with the active branch prefix, ensuring
/// the route is pushed within the correct branch (keeping the BottomNavbar).
class AppNavigator {
  AppNavigator._();

  // ─── Branch detection ──────────────────────────────────────────────────────

  /// Returns the URL prefix of the currently active tab branch.
  /// Uses the global router state so it works from any widget context,
  /// including the GlobalMiniPlayer overlay which lives at the ShellRoute level.
  static String _currentBranchPrefix() {
    final path = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    final segments = path.split('/');
    if (segments.length > 1) {
      final firstSegment = '/${segments[1]}';
      final validPrefixes = [
        '/music',
        '/favorites',
        '/search',
        '/settings',
        '/account'
      ];
      if (validPrefixes.contains(firstSegment)) {
        return firstSegment;
      }
    }
    // Default to root (explore) branch
    return '';
  }

  // ─── Navigation methods ────────────────────────────────────────────────────

  /// Push the Channel page within the current tab branch.
  static void pushChannel(BuildContext context, String channelId) {
    final prefix = _currentBranchPrefix();
    context.push('$prefix/channel', extra: {'channelId': channelId});
  }

  /// Push the Playlist page within the current tab branch.
  static void pushPlaylist(BuildContext context, String playlistId) {
    final prefix = _currentBranchPrefix();
    context.push('$prefix/playlist', extra: {'playlistId': playlistId});
  }

  /// Push the CustomPlaylist page within the current tab branch.
  static void pushCustomPlaylist(
      BuildContext context, CustomPlaylist playlist) {
    final prefix = _currentBranchPrefix();
    context.push('$prefix/custom-playlist', extra: playlist);
  }

  /// Push the Queue page within the current tab branch.
  /// Use only from the MiniPlayer / tab context.
  /// From the full-screen VideoPage, navigate using [AppRoute.queue] instead.
  static void pushQueue(BuildContext context) {
    final matchedRoute = AppRouter.router.state.matchedLocation;
    if (matchedRoute.endsWith('/queue')) return;
    final prefix = _currentBranchPrefix();
    context.push('$prefix/queue');
  }
}
