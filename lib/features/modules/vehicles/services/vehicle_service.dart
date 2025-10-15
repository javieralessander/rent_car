import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Vehicle>> getAll() async {
    return await _client.getList<Vehicle>(
      '/vehiculos',
      (e) => Vehicle.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<List<Vehicle>> getAvailable() async {
    return await _client.getList<Vehicle>(
      '/vehiculos/disponibles',
      (e) => Vehicle.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Vehicle?> getById(int id) async {
    try {
      return await _client.get<Vehicle>(
        '/vehiculos/$id',
        (e) => Vehicle.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Vehicle> create(Vehicle vehiculo) async {
    return await _client.post<Vehicle>(
      '/vehiculos',
      vehiculo.toJson(),
      (e) => Vehicle.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/vehiculos/$id');
  }

  static Future<Vehicle> update(Vehicle vehiculo) async {
    return await _client.put<Vehicle>(
      '/vehiculos/${vehiculo.id}',
      vehiculo.toJson(),
      (e) => Vehicle.fromJson(e as Map<String, dynamic>),
    );
  }
}
