import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpApiClient {
  final String baseUrl;

  HttpApiClient(this.baseUrl);

  Future<T> get<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await http.get(_buildUri(endpoint, queryParams));
      final data = _processResponse(response);
      return fromJson(data);
    } catch (e) {
      throw _handleError(e, 'GET', endpoint);
    }
  }

  Future<List<T>> getList<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await http.get(_buildUri(endpoint, queryParams));
      final data = _processResponse(response);
      return (data as List).map((e) => fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e, 'GET', endpoint);
    }
  }

  Future<T> post<T>(
    String endpoint,
    dynamic body,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = _processResponse(response);
      return fromJson(data);
    } catch (e) {
      throw _handleError(e, 'POST', endpoint);
    }
  }

  Future<T> put<T>(
    String endpoint,
    dynamic body,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = _processResponse(response);
      return fromJson(data);
    } catch (e) {
      throw _handleError(e, 'PUT', endpoint);
    }
  }

  Future<T> patch<T>(
    String endpoint,
    dynamic body,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = _processResponse(response);
      return fromJson(data);
    } catch (e) {
      throw _handleError(e, 'PATCH', endpoint);
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(_buildUri(endpoint));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar recurso: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw _handleError(e, 'DELETE', endpoint);
    }
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams == null || queryParams.isEmpty) return uri;
    final sanitized = queryParams.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return uri.replace(queryParameters: {...uri.queryParameters, ...sanitized});
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  Exception _handleError(dynamic error, String method, String endpoint) {
    if (error is SocketException) {
      return Exception('Sin conexión al servidor. Verifique que el backend esté ejecutándose en $baseUrl');
    } else if (error is HttpException) {
      return Exception('Error de HTTP: ${error.message}');
    } else if (error is FormatException) {
      return Exception('Error de formato en la respuesta del servidor');
    } else if (error.toString().contains('ClientException')) {
      return Exception('Error de conexión: El servidor no responde. Verifique que esté ejecutándose.');
    } else if (error.toString().contains('Failed to fetch')) {
      return Exception('Error de red: No se puede conectar al servidor en $baseUrl');
    } else {
      return Exception('Error inesperado en $method $endpoint: $error');
    }
  }
}
