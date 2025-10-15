import '../config/env.dart';
import '../config/http_api_client.dart';

/// Servicio base genérico para operaciones CRUD
abstract class BaseService<T> {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  /// Endpoint base para este servicio
  String get endpoint;

  /// Función para convertir JSON a objeto
  T Function(Map<String, dynamic>) get fromJson;

  /// Función para convertir objeto a JSON
  Map<String, dynamic> Function(T) get toJson;

  /// Campo ID para operaciones de actualización y eliminación
  dynamic Function(T) get getId;

  /// Obtiene todos los elementos
  Future<List<T>> getAll() async {
    return await _client.getList<T>(
      endpoint,
      (e) => fromJson(e as Map<String, dynamic>),
    );
  }

  /// Obtiene un elemento por ID
  Future<T?> getById(dynamic id) async {
    try {
      return await _client.get<T>(
        '$endpoint/$id',
        (e) => fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  /// Crea un nuevo elemento
  Future<T> create(T item) async {
    return await _client.post<T>(
      endpoint,
      toJson(item),
      (e) => fromJson(e as Map<String, dynamic>),
    );
  }

  /// Actualiza un elemento existente
  Future<T> update(T item) async {
    final id = getId(item);
    return await _client.put<T>(
      '$endpoint/$id',
      toJson(item),
      (e) => fromJson(e as Map<String, dynamic>),
    );
  }

  /// Elimina un elemento por ID
  Future<void> delete(dynamic id) async {
    await _client.delete('$endpoint/$id');
  }

  /// Busca elementos por criterios (override para implementaciones específicas)
  Future<List<T>> search(Map<String, dynamic> criteria) async {
    // Implementación por defecto: obtener todos y filtrar localmente
    final all = await getAll();
    return all; // Las clases hijas pueden implementar filtrado específico
  }

  /// Obtiene elementos paginados
  Future<Map<String, dynamic>> getPaginated({
    int page = 1,
    int size = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (filters != null) {
        filters.forEach((key, value) {
          queryParams[key] = value.toString();
        });
      }

      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);

      return await _client.get<Map<String, dynamic>>(
        uri.toString(),
        (e) => e as Map<String, dynamic>,
      );
    } catch (e) {
      // Si no hay soporte para paginación en el backend, usar getAll
      final all = await getAll();
      final startIndex = (page - 1) * size;
      final endIndex = (startIndex + size).clamp(0, all.length);

      return {
        'content': all.sublist(startIndex, endIndex),
        'totalElements': all.length,
        'totalPages': (all.length / size).ceil(),
        'number': page - 1,
        'size': size,
        'first': page == 1,
        'last': page >= (all.length / size).ceil(),
      };
    }
  }

  /// Verifica si un elemento existe
  Future<bool> exists(dynamic id) async {
    try {
      await getById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cuenta el total de elementos
  Future<int> count() async {
    try {
      final all = await getAll();
      return all.length;
    } catch (e) {
      return 0;
    }
  }
}