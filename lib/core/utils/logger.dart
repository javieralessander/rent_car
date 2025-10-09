import 'package:flutter/foundation.dart';

/// Servicio centralizado para logging y manejo de errores
class Logger {
  static const String _tag = 'RentCarApp';

  /// Log de información (solo en debug)
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }

  /// Log de errores (siempre activo)
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    // En producción, aquí enviarías a un servicio como Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Log de warnings (solo en debug)
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }

  /// Log de debug (solo en debug)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
}
