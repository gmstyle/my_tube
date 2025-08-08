import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/test_youtube_explode/test_youtube_explode_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';

/// Pagina di test per verificare il funzionamento di YoutubeExplodeRepository
/// Questa pagina può essere usata per testare le funzionalità durante la migrazione
class TestYoutubeExplodePage extends StatefulWidget {
  const TestYoutubeExplodePage({super.key});

  @override
  State<TestYoutubeExplodePage> createState() => _TestYoutubeExplodePageState();
}

class _TestYoutubeExplodePageState extends State<TestYoutubeExplodePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test YouTube Explode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sezione per testare ricerca
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Test Search',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter search query...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                context.read<TestYoutubeExplodeBloc>().add(
                                      TestSearchVideos(_searchController.text),
                                    );
                              }
                            },
                            child: const Text('Search'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<TestYoutubeExplodeBloc>().add(
                                    const TestGetTrending(),
                                  );
                            },
                            child: const Text('Get Trending'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sezione per testare video specifico
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Test Single Video',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Test con un video ID di esempio
                        context.read<TestYoutubeExplodeBloc>().add(
                              const TestGetVideo(
                                  'dQw4w9WgXcQ'), // Never Gonna Give You Up
                            );
                      },
                      child: const Text('Test Single Video'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Risultati
            Expanded(
              child:
                  BlocBuilder<TestYoutubeExplodeBloc, TestYoutubeExplodeState>(
                builder: (context, state) {
                  switch (state.status) {
                    case TestYoutubeExplodeStatus.initial:
                      return const Center(
                        child: Text(
                            'Premi un pulsante per testare le funzionalità'),
                      );

                    case TestYoutubeExplodeStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );

                    case TestYoutubeExplodeStatus.success:
                      if (state.resources.isEmpty) {
                        return const Center(
                          child: Text('Nessun risultato trovato'),
                        );
                      }
                      return Column(
                        children: [
                          // Statistiche sui risultati
                          _buildResultsStats(state.resources),
                          const SizedBox(height: 8),
                          // Lista dei risultati
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.resources.length,
                              itemBuilder: (context, index) {
                                final resource = state.resources[index];
                                return _buildResourceTile(resource);
                              },
                            ),
                          ),
                        ],
                      );

                    case TestYoutubeExplodeStatus.failure:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Errore: ${state.errorMessage}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Reset state
                                context.read<TestYoutubeExplodeBloc>().add(
                                      const TestGetTrending(),
                                    );
                              },
                              child: const Text('Riprova'),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Costruisce il tile appropriato in base al tipo di risorsa
  Widget _buildResourceTile(ResourceMT resource) {
    switch (resource.kind) {
      case 'video':
        return _buildVideoTile(resource);
      case 'channel':
        return _buildChannelTile(resource);
      case 'playlist':
        return _buildPlaylistTile(resource);
      default:
        return _buildGenericTile(resource);
    }
  }

  /// Costruisce il widget con le statistiche sui risultati
  Widget _buildResultsStats(List<ResourceMT> resources) {
    final videoCount = resources.where((r) => r.kind == 'video').length;
    final channelCount = resources.where((r) => r.kind == 'channel').length;
    final playlistCount = resources.where((r) => r.kind == 'playlist').length;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(
              icon: Icons.videocam,
              label: 'Video',
              count: videoCount,
              color: Colors.blue,
            ),
            _buildStatChip(
              icon: Icons.person,
              label: 'Canali',
              count: channelCount,
              color: Colors.orange,
            ),
            _buildStatChip(
              icon: Icons.playlist_play,
              label: 'Playlist',
              count: playlistCount,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Costruisce un chip per le statistiche
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Tile per video
  Widget _buildVideoTile(ResourceMT resource) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: resource.thumbnailUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    resource.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.play_circle_outline, size: 40);
                    },
                  ),
                )
              : const Icon(Icons.play_circle_outline, size: 40),
        ),
        title: Text(
          resource.title ?? 'Senza titolo',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.channelTitle != null) ...[
              Text(
                resource.channelTitle!,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.videocam, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                const Text('Video',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (resource.duration != null) ...[
                  const SizedBox(width: 16),
                  Text(_formatDuration(resource.duration!)),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.more_vert),
        onTap: () {
          // Qui si potrebbe aprire il player del video
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video: ${resource.title}')),
          );
        },
      ),
    );
  }

  /// Tile per canale
  Widget _buildChannelTile(ResourceMT resource) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: resource.thumbnailUrl != null
              ? ClipOval(
                  child: Image.network(
                    resource.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.account_circle, size: 40);
                    },
                  ),
                )
              : const Icon(Icons.account_circle, size: 40),
        ),
        title: Text(
          resource.title ?? 'Senza nome',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                const Text('Canale',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (resource.subscriberCount != null) ...[
              const SizedBox(height: 4),
              Text('${resource.subscriberCount} iscritti'),
            ],
            if (resource.videoCount != null) ...[
              const SizedBox(height: 2),
              Text('${resource.videoCount} video'),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Canale: ${resource.title}')),
          );
        },
      ),
    );
  }

  /// Tile per playlist
  Widget _buildPlaylistTile(ResourceMT resource) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              if (resource.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    resource.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.playlist_play, size: 40),
                      );
                    },
                  ),
                )
              else
                const Center(child: Icon(Icons.playlist_play, size: 40)),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.queue_music,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        resource.videoCount ?? '?',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          resource.title ?? 'Senza titolo',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.channelTitle != null) ...[
              Text(
                resource.channelTitle!,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.playlist_play, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                const Text('Playlist',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (resource.videoCount != null) ...[
                  const SizedBox(width: 16),
                  Text('${resource.videoCount} video'),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playlist: ${resource.title}')),
          );
        },
      ),
    );
  }

  /// Tile generico per tipi non riconosciuti
  Widget _buildGenericTile(ResourceMT resource) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: const Icon(Icons.help_outline, size: 40),
        title: Text(
          resource.title ?? 'Elemento sconosciuto',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Tipo: ${resource.kind ?? 'unknown'}'),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }

  /// Formatta la durata da millisecondi a stringa leggibile
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
