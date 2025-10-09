import '../config/api_client_odoo.dart';

class OdooModelService {
  /// Buscar registros (equivalente a search_read)
  static Future<List<dynamic>> searchRead({
    required String model,
    List<dynamic> domain = const [],
    List<String> fields = const [],
    int limit = 20,
  }) async {
    final response = await ApiClientOdoo.post(
      '/web/dataset/call_kw',
      authenticated: true,
      body: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": model,
          "method": "search_read",
          "args": [],
          "kwargs": {"domain": domain, "fields": fields, "limit": limit},
        },
        "id": DateTime.now().millisecondsSinceEpoch,
      },
    );

    return response['body']['result'];
  }

  /// Crear un registro nuevo
  static Future<int> create({
    required String model,
    required Map<String, dynamic> values,
  }) async {
    final response = await ApiClientOdoo.post(
      '/web/dataset/call_kw',
      authenticated: true,
      body: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": model,
          "method": "create",
          "args": [values],
        },
        "id": DateTime.now().millisecondsSinceEpoch,
      },
    );

    return response['body']['result'];
  }

  /// Actualizar un registro por ID
  static Future<bool> write({
    required String model,
    required int id,
    required Map<String, dynamic> values,
  }) async {
    final response = await ApiClientOdoo.post(
      '/web/dataset/call_kw',
      authenticated: true,
      body: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": model,
          "method": "write",
          "args": [
            [id],
            values,
          ],
        },
        "id": DateTime.now().millisecondsSinceEpoch,
      },
    );

    return response['body']['result'];
  }

  /// Eliminar un registro por ID
  static Future<bool> delete({required String model, required int id}) async {
    final response = await ApiClientOdoo.post(
      '/web/dataset/call_kw',
      authenticated: true,
      body: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": model,
          "method": "unlink",
          "args": [
            [id],
          ],
        },
        "id": DateTime.now().millisecondsSinceEpoch,
      },
    );

    return response['body']['result'];
  }
}
