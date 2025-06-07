package it.gmstyle.my_tube

import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import android.util.Log

class AndroidAutoDetector {
    companion object {
        private const val TAG = "AndroidAutoDetector"
        
        /**
         * Rileva se Android Auto è attualmente connesso/attivo
         * Utilizza multiple strategie di rilevamento per maggiore affidabilità
         */
        fun isAndroidAutoActive(context: Context): Boolean {
            return try {
                // Metodo 1: Controlla UI Mode Manager
                val uiModeManager = context.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
                val isCarMode = uiModeManager?.currentModeType == Configuration.UI_MODE_TYPE_CAR
                
                // Metodo 2: Controlla Configuration
                val configuration = context.resources.configuration
                val isCarUiMode = (configuration.uiMode and Configuration.UI_MODE_TYPE_MASK) == Configuration.UI_MODE_TYPE_CAR
                
                // Metodo 3: Controlla se Android Auto package è attivo (opzionale)
                val androidAutoPackages = listOf(
                    "com.google.android.projection.gearhead",
                    "com.google.android.gms.car"
                )
                
                val packageManager = context.packageManager
                var androidAutoInstalled = false
                for (packageName in androidAutoPackages) {
                    try {
                        packageManager.getPackageInfo(packageName, 0)
                        androidAutoInstalled = true
                        break
                    } catch (e: Exception) {
                        // Package non trovato, continua
                    }
                }
                
                val result = isCarMode || isCarUiMode
                
                Log.d(TAG, "Android Auto Detection:")
                Log.d(TAG, "  - UI Mode Manager Car Mode: $isCarMode")
                Log.d(TAG, "  - Configuration Car UI Mode: $isCarUiMode")
                Log.d(TAG, "  - Android Auto Installed: $androidAutoInstalled")
                Log.d(TAG, "  - Final Result: $result")
                
                result
            } catch (e: Exception) {
                Log.e(TAG, "Errore durante il rilevamento di Android Auto", e)
                false
            }
        }
        
        /**
         * Metodo alternativo che controlla anche altre condizioni
         */
        fun isAutomotiveEnvironment(context: Context): Boolean {
            return try {
                // Controlla se l'app è in esecuzione su Android Automotive OS
                val packageManager = context.packageManager
                val hasAutomotiveFeature = packageManager.hasSystemFeature("android.hardware.type.automotive")
                
                // Combina con il controllo di Android Auto
                val isAndroidAuto = isAndroidAutoActive(context)
                
                val result = hasAutomotiveFeature || isAndroidAuto
                
                Log.d(TAG, "Automotive Environment Detection:")
                Log.d(TAG, "  - Has Automotive Feature: $hasAutomotiveFeature")
                Log.d(TAG, "  - Is Android Auto Active: $isAndroidAuto")
                Log.d(TAG, "  - Final Result: $result")
                
                result
            } catch (e: Exception) {
                Log.e(TAG, "Errore durante il rilevamento dell'ambiente automotive", e)
                false
            }
        }
    }
}
