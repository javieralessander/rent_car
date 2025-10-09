import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/rental_model.dart';

class RentalService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Rental>> getAll() async {
    return await _client.getList<Rental>(
      '/rentas',
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Rental> create(Rental renta) async {
    return await _client.post<Rental>(
      '/rentas',
      renta.toJson(),
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/rentas/$id');
  }

  static Future<Rental> update(Rental renta) async {
    return await _client.put<Rental>(
      '/rentas/${renta.id}',
      renta.toJson(),
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Rental> devolver(int id, DateTime fechaDevolucion) async {
    return await _client.patch<Rental>('/rentas/$id', {
      'fechaDevolucion': fechaDevolucion.toIso8601String(),
      'estado': false,
    }, (e) => Rental.fromJson(e as Map<String, dynamic>));
  }

  static Future<List<Rental>> buscarPorCriterios({
    int? clienteId,
    int? vehiculoId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final Map<String, dynamic> query = {};
    if (clienteId != null) query['cliente'] = clienteId;
    if (vehiculoId != null) query['vehiculo'] = vehiculoId;
    if (fechaInicio != null) {
      query['fechaRenta_gte'] = fechaInicio.toIso8601String();
    }
    if (fechaFin != null) query['fechaRenta_lte'] = fechaFin.toIso8601String();

    return await _client.getList<Rental>(
      '/rentas',
      (e) => Rental.fromJson(e as Map<String, dynamic>),
      queryParams: query.isEmpty ? null : query,
    );
  }
}
