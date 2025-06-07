import 'package:flutter/services.dart';
import 'dart:developer' as dev;

class AndroidAutoDetectionService {
  static const MethodChannel _channel = MethodChannel('android_auto_detector');

  static bool _isAndroidAutoActive = false;
  static bool _lastKnownState = false;

  /// Controlla se Android Auto è attualmente attivo
  static Future<bool> isAndroidAutoActive() async {
    try {
      final bool result = await _channel.invokeMethod('isAndroidAutoActive');
      _isAndroidAutoActive = result;
      _lastKnownState = result;
      dev.log('Android Auto detection result: $result');
      return result;
    } on PlatformException catch (e) {
      dev.log('Errore durante il rilevamento di Android Auto: ${e.message}');
      return _lastKnownState; // Fallback all'ultimo stato noto
    } catch (e) {
      dev.log('Errore imprevisto durante il rilevamento di Android Auto: $e');
      return _lastKnownState;
    }
  }

  /// Controlla se l'app è in esecuzione in un ambiente automotive
  static Future<bool> isAutomotiveEnvironment() async {
    try {
      final bool result =
          await _channel.invokeMethod('isAutomotiveEnvironment');
      dev.log('Automotive environment detection result: $result');
      return result;
    } on PlatformException catch (e) {
      dev.log(
          'Errore durante il rilevamento dell\'ambiente automotive: ${e.message}');
      return false;
    } catch (e) {
      dev.log(
          'Errore imprevisto durante il rilevamento dell\'ambiente automotive: $e');
      return false;
    }
  }

  /// Ottiene lo stato corrente senza chiamare il metodo nativo
  static bool get currentAndroidAutoState => _isAndroidAutoActive;

  /// Forza l'aggiornamento dello stato di Android Auto
  static Future<bool> refreshAndroidAutoState() async {
    return await isAndroidAutoActive();
  }

  /// Inizializza il servizio di rilevamento Android Auto
  static Future<void> initialize() async {
    dev.log('Inizializzazione AndroidAutoDetectionService...');
    await isAndroidAutoActive();
    dev.log(
        'AndroidAutoDetectionService inizializzato. Stato iniziale: $_isAndroidAutoActive');
  }
}
