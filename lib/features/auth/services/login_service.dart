import 'package:flutter/material.dart';

import '../../../core/config/api_client_odoo.dart';
import '../../../core/config/secure_storage.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../profile/services/user_profile_service.dart';

class LoginService extends ChangeNotifier {
  String email = 'monterojaviel18@gmail.com';
  String password = 'Code2025*';

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _obscureText = true;
  bool get obscureText => _obscureText;
  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  // Validación de formulario
  bool isValidForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  /// Login contra Odoo (vía JSON-RPC)
  Future<bool> login(BuildContext context) async {
    isLoading = true;

    try {
      final response = await ApiClientOdoo.post(
        '/web/session/authenticate',
        body: {
          "jsonrpc": "2.0",
          "method": "call",
          "params": {
            // "db": Environment.postgres_db,
            "login": 'monterojaviel18@gmail.com',
            "password": 'Code2025*',
            "context": {"lang": "es_DO"},
          },
          "id": DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response['body']['result'];
      final headers = response['headers'];
      final setCookie = headers['set-cookie'] ?? '';

      final sessionId = _extractSessionId(setCookie);
      final userId = result['uid'];

      if (userId == null || userId == false) {
        throw ValidationException('Credenciales inválidas.');
      }

      await SecureStorage.set('session_id', sessionId);
      await SecureStorage.set('user_id', userId.toString());

      await UserProfileService().loadUser();

      return true;
    } catch (e) {
      final error = ErrorHandler.handle(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// Extrae el session_id del header Set-Cookie
  String _extractSessionId(String cookieHeader) {
    final parts = cookieHeader.split(';');
    final sessionCookie = parts.firstWhere(
      (p) => p.trim().startsWith('session_id='),
      orElse: () => '',
    );
    return sessionCookie.replaceAll('session_id=', '').trim();
  }
}
