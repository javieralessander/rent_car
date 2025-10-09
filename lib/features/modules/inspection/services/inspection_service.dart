import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/inspection_model.dart';

class InspectionService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Inspection>> getAll() async {
    return await _client.getList<Inspection>(
      '/inspecciones',
      (e) => Inspection.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Inspection> create(Inspection inspeccion) async {
    return await _client.post<Inspection>(
      '/inspecciones',
      inspeccion.toJson(),
      (e) => Inspection.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/inspecciones/$id');
  }

  static Future<Inspection> update(Inspection inspeccion) async {
    return await _client.put<Inspection>(
      '/inspecciones/${inspeccion.id}',
      inspeccion.toJson(),
      (e) => Inspection.fromJson(e as Map<String, dynamic>),
    );
  }
}
