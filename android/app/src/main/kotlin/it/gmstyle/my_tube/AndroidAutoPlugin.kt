package it.gmstyle.my_tube

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Plugin Flutter per il rilevamento di Android Auto
 * Gestisce la comunicazione tra Flutter e il codice nativo Android
 */
class AndroidAutoPlugin: FlutterPlugin, MethodCallHandler {
    companion object {
        private const val TAG = "AndroidAutoPlugin"
        private const val CHANNEL = "android_auto_detector"
    }

    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "AndroidAutoPlugin attached to engine")
        
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        
        Log.d(TAG, "MethodChannel '$CHANNEL' configurato")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val currentContext = context
        
        Log.d(TAG, "Ricevuta chiamata metodo: ${call.method}")
        
        if (currentContext == null) {
            Log.e(TAG, "Context non disponibile")
            result.error("NO_CONTEXT", "Context Android non disponibile", null)
            return
        }

        when (call.method) {
            "isAndroidAutoActive" -> {
                try {
                    val isActive = AndroidAutoDetector.isAndroidAutoActive(currentContext)
                    Log.d(TAG, "isAndroidAutoActive result: $isActive")
                    result.success(isActive)
                } catch (e: Exception) {
                    Log.e(TAG, "Errore durante il rilevamento di Android Auto", e)
                    result.error("DETECTION_ERROR", "Errore durante il rilevamento di Android Auto: ${e.message}", null)
                }
            }
            
            "isAutomotiveEnvironment" -> {
                try {
                    val isAutomotive = AndroidAutoDetector.isAutomotiveEnvironment(currentContext)
                    Log.d(TAG, "isAutomotiveEnvironment result: $isAutomotive")
                    result.success(isAutomotive)
                } catch (e: Exception) {
                    Log.e(TAG, "Errore durante il rilevamento dell'ambiente automotive", e)
                    result.error("AUTOMOTIVE_DETECTION_ERROR", "Errore durante il rilevamento dell'ambiente automotive: ${e.message}", null)
                }
            }
            
            else -> {
                Log.w(TAG, "Metodo non implementato: ${call.method}")
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "AndroidAutoPlugin detached from engine")
        channel.setMethodCallHandler(null)
        context = null
    }
}