import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/client_model.dart';

class ClientService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Client>> getAll() async {
    return await _client.getList<Client>(
      '/clientes',
      (e) => Client.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Client?> getById(int id) async {
    try {
      return await _client.get<Client>(
        '/clientes/$id',
        (e) => Client.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Client?> getByCedula(String cedula) async {
    try {
      return await _client.get<Client>(
        '/clientes/cedula/$cedula',
        (e) => Client.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Client> create(Client cliente) async {
    return await _client.post<Client>(
      '/clientes',
      cliente.toJson(),
      (e) => Client.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/clientes/$id');
  }

  static Future<Client> update(Client cliente) async {
    return await _client.put<Client>(
      '/clientes/${cliente.id}',
      cliente.toJson(),
      (e) => Client.fromJson(e as Map<String, dynamic>),
    );
  }
}
