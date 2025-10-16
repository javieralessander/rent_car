import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../modules/vehicles/models/vehicle_model.dart';
import '../../modules/clients/models/client_model.dart';
import '../../modules/rental/models/rental_model.dart';

class ChartApiService {
  static String get baseUrl => Environment.apiUrl;

  static Future<List<Vehicle>> fetchVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/vehiculos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar vehículos');
    }
  }

  static Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clientes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar clientes');
    }
  }

  static Future<List<Rental>> fetchRentals() async {
    final response = await http.get(Uri.parse('$baseUrl/rentas'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Rental.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar rentas');
    }
  }

  // Métodos específicos para análisis de datos
  static Future<Map<String, int>> getVehiclesByType() async {
    final vehicles = await fetchVehicles();
    final Map<String, int> grouped = {};

    for (final vehicle in vehicles) {
      final typeKey = 'Tipo ${vehicle.tipoVehiculo}';
      grouped[typeKey] = (grouped[typeKey] ?? 0) + 1;
    }

    return grouped;
  }

  static Future<Map<String, int>> getRentalsByMonth() async {
    final rentals = await fetchRentals();
    final Map<String, int> grouped = {};

    for (final rental in rentals) {
      final monthKey =
          '${rental.fechaRenta.year}-${rental.fechaRenta.month.toString().padLeft(2, '0')}';
      grouped[monthKey] = (grouped[monthKey] ?? 0) + 1;
    }

    return grouped;
  }

  static Future<Map<String, int>> getClientsByType() async {
    final clients = await fetchClients();
    final Map<String, int> grouped = {};

    for (final client in clients) {
      final typeKey = client.tipoPersona.name;
      grouped[typeKey] = (grouped[typeKey] ?? 0) + 1;
    }

    return grouped;
  }
}
