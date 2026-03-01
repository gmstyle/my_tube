import 'dart:developer';

/// Cache generica in-memory con TTL e dimensione massima configurabili.
///
/// Utilizzo:
/// ```dart
/// final cache = AppCache<Video>(ttl: Duration(hours: 1));
/// cache.set('videoId', video);
/// final cached = cache.get('videoId'); // null se scaduto
/// ```
class AppCache<T> {
  final Duration ttl;
  final int maxSize;

  final Map<String, ({T value, DateTime timestamp})> _store = {};

  AppCache({required this.ttl, this.maxSize = 500});

  /// Ritorna il valore associato a [key] se presente e non scaduto,
  /// altrimenti rimuove l'entry (se scaduta) e ritorna null.
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) >= ttl) {
      _store.remove(key);
      log('AppCache: entry "$key" scaduta, rimossa');
      return null;
    }

    log('AppCache: hit "$key"');
    return entry.value;
  }

  /// Salva [value] con la chiave [key] e il timestamp corrente.
  /// Se la cache supera [maxSize], rimuove le entry scadute.
  void set(String key, T value) {
    _store[key] = (value: value, timestamp: DateTime.now());
    log('AppCache: set "$key"');
    _evict();
  }

  /// Rimuove l'entry con chiave [key].
  void invalidate(String key) {
    _store.remove(key);
    log('AppCache: invalidata "$key"');
  }

  /// Svuota interamente la cache.
  void clear() {
    _store.clear();
    log('AppCache: svuotata');
  }

  /// Rimuove le entry scadute quando si supera [maxSize].
  void _evict() {
    if (_store.length <= maxSize) return;
    final now = DateTime.now();
    _store.removeWhere((_, entry) => now.difference(entry.timestamp) >= ttl);
    log('AppCache: eviction eseguita, ${_store.length} entry rimaste');
  }
}
