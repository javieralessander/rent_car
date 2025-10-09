import 'package:flutter/material.dart';
import '../models/user_session_model.dart';
import '../services/local_auth_service.dart';

/// Provider para manejar el estado de autenticación
class AuthProvider with ChangeNotifier {
  final LocalAuthService _authService = LocalAuthService();

  UserSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserSession? get currentSession => _currentSession;
  User? get currentUser => _currentSession?.user;
  bool get isLoggedIn => _currentSession != null && !_currentSession!.isExpired;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicializa el provider verificando si hay una sesión activa
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentSession = await _authService.getCurrentSession();
      _clearError();
    } catch (e) {
      _setError('Error al verificar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
    String? departamento,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        nombre: nombre,
        telefono: telefono,
        departamento: departamento,
      );

      if (result['success']) {
        // Después del registro exitoso, hacer login automático
        return await login(email: email, password: password);
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Error al registrar: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia sesión
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (result['success']) {
        _currentSession = result['session'];
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentSession = null;
      _clearError();
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recuperar contraseña
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.forgotPassword(email);

      if (result['success']) {
        _clearError();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Error al enviar recuperación: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cambiar contraseña
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentSession?.user.email == null) {
      _setError('No hay usuario autenticado');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(
        email: _currentSession!.user.email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result['success']) {
        _clearError();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Error al cambiar contraseña: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _clearError();
  }

  /// Obtener información del usuario actual
  Map<String, String> getUserInfo() {
    final user = currentUser;
    if (user == null) return {};

    return {
      'nombre': user.nombre,
      'email': user.email,
      'telefono': user.telefono ?? 'No especificado',
      'departamento': user.departamento ?? 'No especificado',
      'fechaCreacion': user.fechaCreacion.toString().split(' ')[0],
    };
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Método para desarrollo: obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _authService.getAllUsers();
  }

  /// Método para desarrollo: limpiar todos los datos
  Future<void> clearAllData() async {
    await _authService.clearAllData();
    _currentSession = null;
    _clearError();
  }
}
