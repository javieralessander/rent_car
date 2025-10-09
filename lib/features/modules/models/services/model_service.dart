import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/model_model.dart';

class ModelService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<VehicleModel>> getAll() async {
    return await _client.getList<VehicleModel>(
      '/modelos',
      (e) => VehicleModel.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<VehicleModel> create(VehicleModel modelo) async {
    return await _client.post<VehicleModel>(
      '/modelos',
      modelo.toJson(),
      (e) => VehicleModel.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/modelos/$id');
  }

  static Future<VehicleModel> update(VehicleModel modelo) async {
    return await _client.put<VehicleModel>(
      '/modelos/${modelo.id}',
      modelo.toJson(),
      (e) => VehicleModel.fromJson(e as Map<String, dynamic>),
    );
  }
}
