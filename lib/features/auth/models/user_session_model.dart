import 'dart:convert';

/// Modelo de usuario para el sistema de autenticación
class User {
  final String id;
  final String email;
  final String nombre;
  final String? telefono;
  final String? departamento;
  final DateTime fechaCreacion;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    this.telefono,
    this.departamento,
    required this.fechaCreacion,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      departamento: json['departamento'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'departamento': departamento,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'isActive': isActive,
    };
  }

  String toRawJson() => json.encode(toJson());
  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  @override
  String toString() => 'User(id: $id, email: $email, nombre: $nombre)';
}

/// Datos de sesión del usuario
class UserSession {
  final User user;
  final String token;
  final DateTime expirationTime;

  UserSession({
    required this.user,
    required this.token,
    required this.expirationTime,
  });

  bool get isExpired => DateTime.now().isAfter(expirationTime);

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      user: User.fromJson(json['user']),
      token: json['token'],
      expirationTime: DateTime.parse(json['expirationTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'expirationTime': expirationTime.toIso8601String(),
    };
  }

  String toRawJson() => json.encode(toJson());
  factory UserSession.fromRawJson(String str) =>
      UserSession.fromJson(json.decode(str));
}
