import 'package:rent_car/core/config/http_api_client.dart';
import '../models/dashboard_models.dart';
import '../../modules/vehicles/models/vehicle_model.dart';
import '../../modules/clients/models/client_model.dart';
import '../../modules/rental/models/rental_model.dart';
import '../../modules/inspection/models/inspection_model.dart';

class DashboardService {
  final HttpApiClient _httpClient;

  DashboardService(this._httpClient);

  /// Obtiene resumen general del dashboard
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      // Hacer llamadas paralelas a todos los endpoints con manejo de errores individual
      final futures = [
        _getAllVehicles().catchError((e) {
          print('Error obteniendo vehículos: $e');
          return <Vehicle>[];
        }),
        _getAllClients().catchError((e) {
          print('Error obteniendo clientes: $e');
          return <Client>[];
        }),
        _getAllRentals().catchError((e) {
          print('Error obteniendo rentas: $e');
          return <Rental>[];
        }),
        _getAllInspections().catchError((e) {
          print('Error obteniendo inspecciones: $e');
          return <Inspection>[];
        }),
      ];

      final results = await Future.wait(futures);

      final vehicles = results[0] as List<Vehicle>;
      final clients = results[1] as List<Client>;
      final rentals = results[2] as List<Rental>;
      final inspections = results[3] as List<Inspection>;

      return DashboardSummary(
        totalVehicles: vehicles.length,
        totalClients: clients.length,
        totalActiveRentals: rentals.where((r) => !r.esDevuelto).length,
        totalInspections: inspections.length,
        vehiclesByType: _groupVehiclesByType(vehicles),
        rentalsByMonth: _groupRentalsByMonth(rentals),
        clientsByType: _groupClientsByType(clients),
      );
    } catch (e) {
      print('Error general en getDashboardSummary: $e');
      return DashboardSummary.empty();
    }
  }

  /// Obtiene todos los vehículos
  Future<List<Vehicle>> _getAllVehicles() async {
    return await _httpClient.getList<Vehicle>(
      '/vehiculos',
      (e) => Vehicle.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Obtiene todos los clientes
  Future<List<Client>> _getAllClients() async {
    return await _httpClient.getList<Client>(
      '/clientes',
      (e) => Client.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Obtiene todas las rentas
  Future<List<Rental>> _getAllRentals() async {
    return await _httpClient.getList<Rental>(
      '/rentas',
      (e) => Rental.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Obtiene todas las inspecciones
  Future<List<Inspection>> _getAllInspections() async {
    return await _httpClient.getList<Inspection>(
      '/inspecciones',
      (e) => Inspection.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Agrupa vehículos por tipo
  Map<String, int> _groupVehiclesByType(List<Vehicle> vehicles) {
    final Map<String, int> grouped = {};
    for (final vehicle in vehicles) {
      final typeKey = 'Tipo ${vehicle.tipoVehiculo}';
      grouped[typeKey] = (grouped[typeKey] ?? 0) + 1;
    }
    return grouped;
  }

  /// Agrupa rentas por mes
  Map<String, int> _groupRentalsByMonth(List<Rental> rentals) {
    final Map<String, int> grouped = {};
    for (final rental in rentals) {
      final monthKey =
          '${rental.fechaRenta.year}-${rental.fechaRenta.month.toString().padLeft(2, '0')}';
      grouped[monthKey] = (grouped[monthKey] ?? 0) + 1;
    }
    return grouped;
  }

  /// Agrupa clientes por tipo
  Map<String, int> _groupClientsByType(List<Client> clients) {
    final Map<String, int> grouped = {};
    for (final client in clients) {
      final typeKey = client.tipoPersona.name;
      grouped[typeKey] = (grouped[typeKey] ?? 0) + 1;
    }
    return grouped;
  }

  /// Obtiene datos para gráficos específicos
  Future<Map<String, dynamic>> getChartData() async {
    try {
      final summary = await getDashboardSummary();
      return {
        'vehiclesByType': summary.vehiclesByType,
        'rentalsByMonth': summary.rentalsByMonth,
        'clientsByType': summary.clientsByType,
      };
    } catch (e) {
      print('Error obteniendo datos para gráficos: $e');
      return {};
    }
  }
}
