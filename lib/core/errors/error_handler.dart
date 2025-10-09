import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'app_exception.dart';

class ErrorHandler {
  static AppException handleOdoo(String responseBody) {
    try {
      final jsonData = json.decode(responseBody);

      if (jsonData is Map && jsonData.containsKey('error')) {
        final error = jsonData['error'];
        final data = error['data'] ?? {};

        final String exceptionName = data['name'] ?? '';
        final String message =
            data['message'] ?? error['message'] ?? 'Error desconocido';

        if (exceptionName.contains('AccessDenied')) {
          return UnauthorizedException(message); // mensaje real aquí
        }

        if (exceptionName.contains('UserError') ||
            exceptionName.contains('ValidationError')) {
          return ValidationException(message);
        }

        return OdooServerException(message); // mensaje real
      }

      return UnknownException('Respuesta sin formato de error válido.');
    } catch (_) {
      return UnknownException('Error al interpretar el error de Odoo.');
    }
  }

  static AppException handle(dynamic error) {
    if (error is AppException) return error;

    if (error is SocketException) return NetworkException();
    if (error is http.Response) {
      if (error.statusCode == 401) return UnauthorizedException();
      if (error.statusCode == 404) return NotFoundException();
      if (error.statusCode >= 500) return ServerException();

      if (error.body.contains('"error"')) {
        return handleOdoo(error.body);
      }

      return UnknownException(
        'Respuesta HTTP no manejada: ${error.statusCode}',
      );
    }

    return UnknownException(error.toString());
  }
}
