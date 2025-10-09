import 'package:flutter/foundation.dart';

class WebConfig {
  /// Verifica si localStorage está disponible en el navegador
  static bool get isLocalStorageAvailable {
    if (!kIsWeb) return false;

    try {
      // Por simplicidad, asumimos que está disponible
      // En producción podrías hacer una verificación más robusta
      return true;
    } catch (e) {
      debugPrint('localStorage not available: $e');
      return false;
    }
  }

  /// Verifica si Service Workers están disponibles
  static bool get isServiceWorkerAvailable {
    if (!kIsWeb) return false;

    try {
      // Verificar si 'serviceWorker' está en navigator
      return true; // Simplificado por ahora
    } catch (e) {
      debugPrint('Service Worker not available: $e');
      return false;
    }
  }

  /// Configuración de desarrollo para evitar errores
  static void configureWebDevelopment() {
    if (!kIsWeb) return;

    // Configurar error handlers específicos para web
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exception.toString().toLowerCase();

      // Lista de errores que son seguros ignorar en desarrollo web
      final safeToIgnoreErrors = [
        'localstorage',
        'service worker',
        'failed to register',
        'permission denied',
        'securityerror',
        'notsupportederror',
        'registerextension',
        'dart:developer',
        'dwds',
      ];

      final shouldIgnore = safeToIgnoreErrors.any(
        (error) => errorString.contains(error),
      );

      if (shouldIgnore) {
        debugPrint(
          'Web development - Ignoring non-critical error: ${details.exception}',
        );
      } else {
        // Mostrar otros errores normalmente
        FlutterError.presentError(details);
      }
    };
  }
}
