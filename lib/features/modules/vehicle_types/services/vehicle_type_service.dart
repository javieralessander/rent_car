import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/vehicle_type_model.dart';

class VehicleTypeService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<VehicleType>> getAll() async {
    return await _client.getList<VehicleType>(
      '/tipos-vehiculos',
      (e) => VehicleType.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<VehicleType?> getById(int id) async {
    return await _client.get<VehicleType>(
      '/tipos-vehiculos/$id',
      (e) => VehicleType.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<VehicleType> create(VehicleType tipoVehiculo) async {
    return await _client.post<VehicleType>(
      '/tipos-vehiculos',
      tipoVehiculo.toJson(),
      (e) => VehicleType.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/tipos-vehiculos/$id');
  }

  static Future<VehicleType> update(VehicleType tipoVehiculo) async {
    return await _client.put<VehicleType>(
      '/tipos-vehiculos/${tipoVehiculo.id}',
      tipoVehiculo.toJson(),
      (e) => VehicleType.fromJson(e as Map<String, dynamic>),
    );
  }
}
