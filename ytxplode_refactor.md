# Piano di Migrazione da innertube_dart a youtube_explode_dart

## Panoramica

Questo documento descrive il piano per sostituire la libreria `innertube_dart` con `youtube_explode_dart` nell'app My Tube, mantenendo tutte le funzionalità esistenti.

## Analisi delle Funzionalità Attuali

### Funzionalità di innertube_dart utilizzate:
1. **getVideo()** - Recupero metadati video con URL di streaming
2. **getPlaylist()** - Recupero informazioni playlist e video contenuti
3. **getTrending()** - Recupero video di tendenza per categoria
4. **getMusicHome()** - Recupero contenuti della home page music
5. **searchContents()** - Ricerca di video, canali e playlist
6. **getSearchSuggestions()** - Suggerimenti di ricerca
7. **getChannel()** - Recupero informazioni canale e contenuti

### Funzionalità di youtube_explode_dart disponibili:
✅ **Video metadata** - `yt.videos.get()`
✅ **Video streams** - `yt.videos.streamsClient.getManifest()`
✅ **Playlists** - `yt.playlists.get()` e `yt.playlists.getVideos()`
✅ **Search** - `yt.search.getVideos()`, `yt.search.getChannels()`, `yt.search.getPlaylists()`
✅ **Channels** - `yt.channels.get()` e `yt.channels.getUploads()`
✅ **Related videos** - `yt.videos.getRelatedVideos()`
✅ **Comments** - `yt.videos.comments.getComments()`
✅ **Closed captions** - `yt.videos.closedCaptions.getManifest()`

### Funzionalità NON direttamente disponibili in youtube_explode_dart:
❌ **getTrending()** - Non esiste API diretta per trending
❌ **getMusicHome()** - Non esiste API diretta per home page music
❌ **getSearchSuggestions()** - Non esiste API per suggerimenti di ricerca

## Piano di Migrazione

### Fase 1: Preparazione
1. **Aggiornare pubspec.yaml**
   - Rimuovere `innertube_dart` dalle dipendenze
   - Mantenere `youtube_explode_dart: ^2.5.2` (già presente)

2. **Creare nuovo provider**
   - Creare `YoutubeExplodeProvider` per sostituire `InnertubeProvider`
   - Implementare le funzionalità base disponibili

### Fase 2: Implementazione Core
1. **Video Service**
   ```dart
   // Sostituzione diretta
   Future<Video> getVideo(String videoId) async {
     final yt = YoutubeExplode();
     final video = await yt.videos.get(videoId);
     final manifest = await yt.videos.streamsClient.getManifest(videoId);
     final streamInfo = manifest.muxed.bestQuality ?? manifest.videoOnly.withHighestVideoQuality();
     return video; // + aggiungere streamUrl dal manifest
   }
   ```

2. **Playlist Service**
   ```dart
   Future<Playlist> getPlaylist(String playlistId) async {
     final yt = YoutubeExplode();
     final playlist = await yt.playlists.get(playlistId);
     final videos = await yt.playlists.getVideos(playlistId).toList();
     return playlist; // + videos
   }
   ```

3. **Search Service**
   ```dart
   Future<SearchResults> searchContents(String query) async {
     final yt = YoutubeExplode();
     final videos = await yt.search.getVideos(query).take(20).toList();
     final channels = await yt.search.getChannels(query).take(10).toList();
     final playlists = await yt.search.getPlaylists(query).take(10).toList();
     return SearchResults(videos, channels, playlists);
   }
   ```

4. **Channel Service**
   ```dart
   Future<Channel> getChannel(String channelId) async {
     final yt = YoutubeExplode();
     final channel = await yt.channels.get(channelId);
     final uploads = await yt.channels.getUploads(channelId).take(50).toList();
     return channel; // + uploads
   }
   ```

### Fase 3: Workaround per Funzionalità Mancanti

#### 3.1 Trending Videos
**Problema**: YouTube Explode non ha API per trending
**Soluzione**: 
- Utilizzare ricerche predefinite per categorie popolari
- Implementare logica per recuperare video recenti di canali popolari
- Alternative:
  ```dart
  // Simulare trending con ricerche per argomenti popolari
  Future<List<Video>> getTrending(TrendingCategory category) async {
    final queries = {
      TrendingCategory.music: ['music 2024', 'top songs', 'new music'],
      TrendingCategory.gaming: ['gaming', 'gameplay', 'games 2024'],
      TrendingCategory.film: ['movies 2024', 'movie trailers', 'films'],
    };
    
    final results = <Video>[];
    for (final query in queries[category] ?? ['popular']) {
      final videos = await yt.search.getVideos(query).take(10).toList();
      results.addAll(videos);
    }
    return results;
  }
  ```

#### 3.2 Music Home
**Problema**: YouTube Explode non ha API per music home
**Soluzione**:
- Creare sezioni basate su ricerche musicali predefinite
- Utilizzare playlist musicali popolari
- Implementare carousel con video musicali trending
  ```dart
  Future<MusicHome> getMusicHome() async {
    final sections = <MusicSection>[];
    
    // Sezione "Top Music"
    final topMusic = await yt.search.getVideos('top music 2024').take(20).toList();
    sections.add(MusicSection('Top Music', topMusic));
    
    // Sezione "New Releases"
    final newReleases = await yt.search.getVideos('new music releases').take(20).toList();
    sections.add(MusicSection('New Releases', newReleases));
    
    return MusicHome(sections);
  }
  ```

#### 3.3 Search Suggestions
**Problema**: YouTube Explode non ha API per suggerimenti
**Soluzione**:
- Implementare cache locale di query precedenti
- Utilizzare suggerimenti predefiniti per categorie
- Integrazione con API esterne (opzionale)
  ```dart
  Future<List<String>> getSearchSuggestions(String query) async {
    // Cache locale delle ricerche precedenti
    final previousQueries = await _getHistoryQueries(query);
    
    // Suggerimenti predefiniti
    final predefinedSuggestions = _getPredefinedSuggestions(query);
    
    return [...previousQueries, ...predefinedSuggestions];
  }
  ```

### Fase 4: Refactoring dei Repository

1. **InnertubeRepository → YoutubeExplodeRepository**
   - Mantenere la stessa interfaccia pubblica
   - Modificare solo l'implementazione interna
   - Aggiornare i mapping per i modelli MT

2. **Mapping dei Modelli**
   ```dart
   // youtube_explode_dart Video → ResourceMT
   Future<ResourceMT> mapVideoToResourceMT(Video video) async {
     final manifest = await yt.videos.streamsClient.getManifest(video.id);
     final streamInfo = manifest.muxed.bestQuality;
     
     return ResourceMT(
       id: video.id.value,
       title: video.title,
       description: video.description,
       channelTitle: video.author,
       thumbnailUrl: video.thumbnails.mediumResUrl,
       streamUrl: streamInfo?.url.toString(),
       duration: video.duration?.inMilliseconds,
       // ... altri campi
     );
   }
   ```

### Fase 5: Testing e Validazione

1. **Test delle funzionalità core**
   - Video playback
   - Search
   - Playlists
   - Channel navigation

2. **Test delle funzionalità simulate**
   - Trending (con ricerche simulate)
   - Music home (con sezioni predefinite)
   - Search suggestions (con cache locale)

3. **Performance testing**
   - Confronto tempi di risposta
   - Memory usage
   - Cache efficiency

### Fase 6: Deploy Graduale

1. **Feature Flag**
   ```dart
   class FeatureFlags {
     static const useYoutubeExplode = bool.fromEnvironment('USE_YOUTUBE_EXPLODE', defaultValue: false);
   }
   ```

2. **Rollback Plan**
   - Mantenere temporaneamente entrambe le librerie
   - Switch rapido in caso di problemi
   - Monitoraggio degli errori

## Vantaggi della Migrazione

### ✅ Pro:
1. **Manutenzione attiva** - youtube_explode_dart è più attivamente mantenuto
2. **Performance** - Potenzialmente più veloce per operazioni di base
3. **Semplicità** - API più pulita e diretta
4. **Streaming** - Migliore gestione degli stream di download
5. **Stabilità** - Meno dipendente da cambiamenti interni di YouTube

### ⚠️ Contro:
1. **Funzionalità limitate** - Manca trending e music home nativi
2. **Workaround necessari** - Alcune funzionalità richiedono soluzioni alternative
3. **Testing estensivo** - Necessario testare tutte le funzionalità simulate

## Timeline Stimata

- **Fase 1-2**: 2-3 giorni (Setup e implementazione core)
- **Fase 3**: 3-4 giorni (Workaround per funzionalità mancanti)  
- **Fase 4**: 2-3 giorni (Refactoring repository)
- **Fase 5**: 2-3 giorni (Testing)
- **Fase 6**: 1-2 giorni (Deploy)

**Totale**: 10-15 giorni

## Conclusioni

La migrazione è **fattibile** ma richiede workaround creativi per alcune funzionalità. Il risultato finale manterrà tutte le funzionalità utente esistenti, anche se alcune (trending, music home) saranno implementate diversamente sotto il cofano.

**Raccomandazione**: Procedere con la migrazione, implementando prima le funzionalità core e poi i workaround per le funzionalità avanzate.
