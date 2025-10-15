import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/rental_model.dart';
import '../models/rental_form.dart';

class RentalService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Rental>> getAll() async {
    return await _client.getList<Rental>(
      '/rentas',
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Rental?> getById(int id) async {
    try {
      return await _client.get<Rental>(
        '/rentas/$id',
        (e) => Rental.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<List<Rental>> getByCliente(int clienteId) async {
    return await _client.getList<Rental>(
      '/rentas/cliente/$clienteId',
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<List<Rental>> getReporte({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final Map<String, dynamic> query = {};
    if (fechaInicio != null) query['fechaInicio'] = fechaInicio;
    if (fechaFin != null) query['fechaFin'] = fechaFin;

    return await _client.getList<Rental>(
      '/rentas/reporte',
      (e) => Rental.fromJson(e as Map<String, dynamic>),
      queryParams: query.isEmpty ? null : query,
    );
  }

  static Future<Rental> create(Rental renta) async {
    return await _client.post<Rental>(
      '/rentas',
      renta.toJson(),
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  // Método alternativo que usa RentalForm directamente
  static Future<Rental> createFromForm(RentalForm rentalForm) async {
    return await _client.post<Rental>(
      '/rentas',
      rentalForm.toApiJson(),
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/rentas/$id');
  }

  static Future<Rental> update(Rental renta) async {
    return await _client.put<Rental>(
      '/rentas/${renta.noRenta}',
      renta.toJson(),
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Rental> devolver(int id) async {
    return await _client.put<Rental>(
      '/rentas/$id/devolver',
      {},
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

}
