import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/model_model.dart';

class ModelService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Model>> getAll() async {
    return await _client.getList<Model>(
      '/modelos',
      (e) => Model.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Model?> getById(int id) async {
    try {
      return await _client.get<Model>(
        '/modelos/$id',
        (e) => Model.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Model> create(Model modelo) async {
    return await _client.post<Model>(
      '/modelos',
      modelo.toJson(),
      (e) => Model.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/modelos/$id');
  }

  static Future<Model> update(Model modelo) async {
    return await _client.put<Model>(
      '/modelos/${modelo.id}',
      modelo.toJson(),
      (e) => Model.fromJson(e as Map<String, dynamic>),
    );
  }
}
