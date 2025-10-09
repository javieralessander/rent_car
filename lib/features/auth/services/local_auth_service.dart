import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session_model.dart';

/// Servicio para manejar autenticación con almacenamiento local
/// Simula una base de datos hasta que esté listo el backend
class LocalAuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentSessionKey = 'current_session';
  static const String _rememberMeKey = 'remember_me';

  /// Registra un nuevo usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
    String? departamento,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verificar si el email ya existe
      final users = await _getStoredUsers();
      if (users.any((user) => user['email'] == email)) {
        return {'success': false, 'message': 'Este email ya está registrado'};
      }

      // Crear nuevo usuario
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final hashedPassword = _hashPassword(password);

      final newUser = {
        'id': userId,
        'email': email,
        'password': hashedPassword,
        'nombre': nombre,
        'telefono': telefono,
        'departamento': departamento,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      // Agregar a la lista de usuarios
      users.add(newUser);
      await prefs.setString(_usersKey, json.encode(users));

      return {
        'success': true,
        'message': 'Usuario registrado exitosamente',
        'user': _userToSafeMap(newUser),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al registrar usuario: $e'};
    }
  }

  /// Inicia sesión
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final users = await _getStoredUsers();
      final hashedPassword = _hashPassword(password);

      // Buscar usuario
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == hashedPassword,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return {'success': false, 'message': 'Email o contraseña incorrectos'};
      }

      if (user['isActive'] != true) {
        return {'success': false, 'message': 'Usuario desactivado'};
      }

      // Crear sesión
      final token = _generateToken();
      final sessionDuration = rememberMe ? 30 : 1; // 30 días o 1 día
      final expirationTime = DateTime.now().add(
        Duration(days: sessionDuration),
      );

      final session = UserSession(
        user: User.fromJson(_userToSafeMap(user)),
        token: token,
        expirationTime: expirationTime,
      );

      // Guardar sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentSessionKey, session.toRawJson());
      await prefs.setBool(_rememberMeKey, rememberMe);

      return {
        'success': true,
        'message': 'Inicio de sesión exitoso',
        'session': session,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al iniciar sesión: $e'};
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentSessionKey);
    await prefs.remove(_rememberMeKey);
  }

  /// Obtiene la sesión actual
  Future<UserSession?> getCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_currentSessionKey);

      if (sessionJson == null) return null;

      final session = UserSession.fromRawJson(sessionJson);

      // Verificar si la sesión ha expirado
      if (session.isExpired) {
        await logout();
        return null;
      }

      return session;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay una sesión activa
  Future<bool> isLoggedIn() async {
    final session = await getCurrentSession();
    return session != null;
  }

  /// Recuperar contraseña (simulado)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final users = await _getStoredUsers();
      final userExists = users.any((user) => user['email'] == email);

      if (!userExists) {
        return {
          'success': false,
          'message': 'No se encontró un usuario con este email',
        };
      }

      // En un escenario real, aquí se enviaría un email
      // Por ahora, simulamos que se envió
      return {
        'success': true,
        'message': 'Se ha enviado un link de recuperación a tu email',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al procesar solicitud: $e'};
    }
  }

  /// Cambiar contraseña
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getStoredUsers();
      final oldHashedPassword = _hashPassword(oldPassword);
      final newHashedPassword = _hashPassword(newPassword);

      // Encontrar el usuario
      final userIndex = users.indexWhere(
        (user) =>
            user['email'] == email && user['password'] == oldHashedPassword,
      );

      if (userIndex == -1) {
        return {'success': false, 'message': 'Contraseña actual incorrecta'};
      }

      // Actualizar contraseña
      users[userIndex]['password'] = newHashedPassword;
      await prefs.setString(_usersKey, json.encode(users));

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al cambiar contraseña: $e'};
    }
  }

  /// Obtener todos los usuarios registrados (para debug)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final users = await _getStoredUsers();
    return users.map((user) => _userToSafeMap(user)).toList();
  }

  /// Limpiar todos los datos (para desarrollo/debug)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentSessionKey);
    await prefs.remove(_rememberMeKey);
  }

  // Métodos privados
  Future<List<Map<String, dynamic>>> _getStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final usersList = json.decode(usersJson) as List;
    return usersList.cast<Map<String, dynamic>>();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomString = DateTime.now().microsecondsSinceEpoch.toString();
    return _hashPassword(timestamp + randomString);
  }

  Map<String, dynamic> _userToSafeMap(Map<String, dynamic> user) {
    final safeUser = Map<String, dynamic>.from(user);
    safeUser.remove('password'); // No exponer la contraseña
    return safeUser;
  }
}
