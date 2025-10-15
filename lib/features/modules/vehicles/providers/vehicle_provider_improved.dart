import '../../../../core/providers/base_collection_provider.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

/// Provider mejorado para vehículos usando el provider base
class VehicleProviderImproved extends BaseCollectionProvider<Vehicle> {
  @override
  Future<List<Vehicle>> fetchAll() async {
    return await VehicleService.getAll();
  }

  @override
  Future<Vehicle> create(Vehicle item) async {
    return await VehicleService.create(item);
  }

  @override
  Future<Vehicle> update(Vehicle item) async {
    return await VehicleService.update(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    await VehicleService.delete(id);
  }

  @override
  bool matchesSearch(Vehicle item, String searchTerm) {
    return item.descripcion.toLowerCase().contains(searchTerm) ||
           item.noPlaca.toLowerCase().contains(searchTerm) ||
           item.noChasis.toLowerCase().contains(searchTerm) ||
           item.noMotor.toLowerCase().contains(searchTerm) ||
           item.estado.toString().toLowerCase().contains(searchTerm) ||
           (item.tipoVehiculo?.descripcion.toLowerCase().contains(searchTerm) ?? false) ||
           (item.marca?.descripcion.toLowerCase().contains(searchTerm) ?? false) ||
           (item.modelo?.descripcion.toLowerCase().contains(searchTerm) ?? false);
  }

  @override
  dynamic getId(Vehicle item) => item.id;

  // Métodos específicos para vehículos

  /// Obtiene vehículos disponibles para renta
  Future<List<Vehicle>> getAvailableVehicles() async {
    try {
      return await VehicleService.getAvailable();
    } catch (e) {
      return [];
    }
  }

  /// Filtra vehículos por estado
  void filterByStatus(bool? activo) {
    if (activo == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((vehicle) => vehicle.estado == activo);
    }
  }

  /// Filtra vehículos por tipo
  void filterByType(int? tipoId) {
    if (tipoId == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((vehicle) => vehicle.tipoVehiculo?.id == tipoId);
    }
  }

  /// Filtra vehículos por marca
  void filterByBrand(int? marcaId) {
    if (marcaId == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((vehicle) => vehicle.marca?.id == marcaId);
    }
  }

  /// Limpia filtros personalizados y restaura vista normal
  void clearCustomFilter() {
    resetPagination();
    // La vista se actualiza automáticamente
  }

  /// Busca vehículos por placa
  List<Vehicle> findByPlate(String plate) {
    if (plate.isEmpty) return [];
    return allItems.where((v) =>
      v.noPlaca.toLowerCase().contains(plate.toLowerCase())
    ).toList();
  }

  /// Busca vehículos por chasis
  List<Vehicle> findByChasis(String chasis) {
    if (chasis.isEmpty) return [];
    return allItems.where((v) =>
      v.noChasis.toLowerCase().contains(chasis.toLowerCase())
    ).toList();
  }

  /// Obtiene estadísticas de vehículos
  Map<String, int> getVehicleStats() {
    final activos = allItems.where((v) => v.estado).length;
    final inactivos = allItems.length - activos;

    return {
      'total': allItems.length,
      'activos': activos,
      'inactivos': inactivos,
    };
  }

  /// Obtiene vehículos agrupados por tipo
  Map<String, List<Vehicle>> getVehiclesByType() {
    final grouped = <String, List<Vehicle>>{};

    for (final vehicle in allItems) {
      final tipo = vehicle.tipoVehiculo?.descripcion ?? 'Sin tipo';
      grouped.putIfAbsent(tipo, () => []).add(vehicle);
    }

    return grouped;
  }
}