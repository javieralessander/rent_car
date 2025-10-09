import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'env.dart';
import 'secure_storage.dart';

import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

class ApiClientOdoo {
  static final String _baseUrl = Environment.apiUrl;

  static Future<Map<String, dynamic>> _sendRequest(
    String method,
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool authenticated = false,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$path');

    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept-Language': 'es_DO',
      ...?headers,
    };

    if (authenticated) {
      final sessionId = await SecureStorage.get('session_id');
      if (sessionId != null) {
        defaultHeaders['Cookie'] = 'session_id=$sessionId';
      }
    }

    final encodedBody = body != null ? json.encode(body) : null;

    try {
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: defaultHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: defaultHeaders,
            body: encodedBody,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: defaultHeaders,
            body: encodedBody,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: defaultHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 400) {
        throw ErrorHandler.handle(response);
      }

      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('error')) {
        throw ErrorHandler.handleOdoo(response.body);
      }

      return {'body': decoded, 'headers': response.headers};
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw ServerException();
    } on FormatException {
      throw UnknownException('Error al procesar respuesta del servidor');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    bool authenticated = false,
  }) async {
    return await _sendRequest(
      'GET',
      path,
      headers: headers,
      authenticated: authenticated,
    );
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool authenticated = false,
  }) async {
    return await _sendRequest(
      'POST',
      path,
      headers: headers,
      body: body,
      authenticated: authenticated,
    );
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool authenticated = false,
  }) async {
    return await _sendRequest(
      'PUT',
      path,
      headers: headers,
      body: body,
      authenticated: authenticated,
    );
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    bool authenticated = false,
  }) async {
    return await _sendRequest(
      'DELETE',
      path,
      headers: headers,
      authenticated: authenticated,
    );
  }
}
