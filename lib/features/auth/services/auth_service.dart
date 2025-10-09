import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/secure_storage.dart';

class AuthService extends ChangeNotifier {
  String emailAddress = "";

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> isValidSession() async {
    try {
      final sessionId = await SecureStorage.get('session_id');
      if (sessionId == null) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final session = await SecureStorage.get('session_id');
    return session != null;
  }
}
