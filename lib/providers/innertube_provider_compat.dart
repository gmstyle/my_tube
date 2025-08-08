import 'package:my_tube/providers/base_provider.dart';
import 'package:my_tube/providers/youtube_explode_provider.dart';

/// Provider temporaneo per mantenere compatibilità durante la transizione
/// Questo wrappa YoutubeExplodeProvider per fornire la stessa interfaccia di InnertubeProvider
class InnertubeProvider extends BaseProvider {
  late final YoutubeExplodeProvider _delegate;

  InnertubeProvider() {
    _delegate = YoutubeExplodeProvider();
  }

  // Metodi di compatibilità che delegano a YoutubeExplodeProvider
  // Questi saranno rimossi una volta completata la migrazione

  // Per ora, semplicemente esponiamo il delegate
  YoutubeExplodeProvider get delegate => _delegate;
}
