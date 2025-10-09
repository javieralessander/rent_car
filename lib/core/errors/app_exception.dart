abstract class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, [this.details]);

  @override
  String toString() => '$runtimeType: $message';
}

// Errores generales
class NetworkException extends AppException {
  NetworkException([String? details])
    : super('Sin conexión a internet', details);
}

class TimeoutException extends AppException {
  TimeoutException([String? details])
    : super('Tiempo de espera agotado', details);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) : super(message ?? 'No autorizado');
}

class NotFoundException extends AppException {
  NotFoundException([String? details])
    : super('Recurso no encontrado', details);
}

class ValidationException extends AppException {
  ValidationException([String? details])
    : super('Error de validación', details);
}

class ServerException extends AppException {
  ServerException([String? details])
    : super('Error interno del servidor', details);
}

class OdooServerException extends AppException {
  OdooServerException([String? message])
    : super(message ?? 'Error del servidor Odoo');
}

class UnknownException extends AppException {
  UnknownException([String? message]) : super(message ?? 'Error desconocido');
}
