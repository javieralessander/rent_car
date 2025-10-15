import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/fuel_type_model.dart';

class FuelTypeService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<FuelType>> getAll() async {
    return await _client.getList<FuelType>(
      '/tipos-combustibles',
      (e) => FuelType.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<FuelType?> getById(int id) async {
    return await _client.get<FuelType>(
      '/tipos-combustibles/$id',
      (e) => FuelType.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<FuelType> create(FuelType tipoCombustible) async {
    return await _client.post<FuelType>(
      '/tipos-combustibles',
      tipoCombustible.toJson(),
      (e) => FuelType.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/tipos-combustibles/$id');
  }

  static Future<FuelType> update(FuelType tipoCombustible) async {
    return await _client.put<FuelType>(
      '/tipos-combustibles/${tipoCombustible.id}',
      tipoCombustible.toJson(),
      (e) => FuelType.fromJson(e as Map<String, dynamic>),
    );
  }
}
