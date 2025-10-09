import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: "SistemaRentcarDB",
      publicKey: "SistemaRentcarPublicKey",
    ),
  );

  /// Guarda un valor
  static Future<void> set(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kIsWeb) {
        // En web, si localStorage no está disponible, usar memoria temporal
        debugPrint('SecureStorage error: $e. Using memory fallback.');
        _memoryStorage[key] = value;
      } else {
        rethrow;
      }
    }
  }

  /// Obtiene un valor
  static Future<String?> get(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kIsWeb) {
        // En web, si localStorage no está disponible, usar memoria temporal
        debugPrint('SecureStorage error: $e. Using memory fallback.');
        return _memoryStorage[key];
      } else {
        rethrow;
      }
    }
  }

  /// Elimina un valor
  static Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kIsWeb) {
        debugPrint('SecureStorage error: $e. Using memory fallback.');
        _memoryStorage.remove(key);
      } else {
        rethrow;
      }
    }
  }

  /// Limpia todo el almacenamiento seguro
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kIsWeb) {
        debugPrint('SecureStorage error: $e. Using memory fallback.');
        _memoryStorage.clear();
      } else {
        rethrow;
      }
    }
  }

  // Almacenamiento en memoria como fallback para web
  static final Map<String, String> _memoryStorage = <String, String>{};
}
