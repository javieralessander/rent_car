import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardProvider(this._dashboardService);

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Datos del dashboard
  DashboardSummary? _summary;
  DashboardSummary? get summary => _summary;

  List<RentCarAlert> _alerts = [];
  List<RentCarAlert> get alerts => _alerts;

  // Datos para los gráficos
  Map<String, int> _vehiclesByType = {};
  Map<String, int> get vehiclesByType => _vehiclesByType;

  Map<String, int> _rentalsByMonth = {};
  Map<String, int> get rentalsByMonth => _rentalsByMonth;

  Map<String, int> _clientsByType = {};
  Map<String, int> get clientsByType => _clientsByType;

  // Error handling
  String? _error;
  String? get error => _error;

  /// Carga todos los datos del dashboard
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _dashboardService.getDashboardSummary();

      if (_summary != null) {
        _vehiclesByType = _summary!.vehiclesByType;
        _rentalsByMonth = _summary!.rentalsByMonth;
        _clientsByType = _summary!.clientsByType;

        // Generar alertas basadas en los datos
        _generateAlerts();
      }
    } catch (e) {
      _error = 'Error al cargar datos del dashboard: $e';
      if (kDebugMode) {
        print(_error);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Actualiza solo el resumen sin recargar todo
  Future<void> refreshSummary() async {
    try {
      _summary = await _dashboardService.getDashboardSummary();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar resumen: $e');
      }
    }
  }

  /// Genera alertas basadas en los datos actuales
  void _generateAlerts() {
    _alerts.clear();

    if (_summary != null) {
      // Alerta de vehículos disponibles
      if (_summary!.totalVehicles < 5) {
        _alerts.add(
          RentCarAlert(
            type: 'warning',
            message: 'Pocos vehículos disponibles',
            count: _summary!.totalVehicles,
            actionLabel: 'Ver Vehículos',
            actionRoute: '/vehiculos',
          ),
        );
      }

      // Alerta de rentas activas
      if (_summary!.totalActiveRentals > 10) {
        _alerts.add(
          RentCarAlert(
            type: 'info',
            message: 'Muchas rentas activas',
            count: _summary!.totalActiveRentals,
            actionLabel: 'Ver Rentas',
            actionRoute: '/rentas',
          ),
        );
      }

      // Alerta de clientes nuevos
      if (_summary!.totalClients < 3) {
        _alerts.add(
          RentCarAlert(
            type: 'warning',
            message: 'Pocos clientes registrados',
            count: _summary!.totalClients,
            actionLabel: 'Ver Clientes',
            actionRoute: '/clientes',
          ),
        );
      }
    }
  }

  /// Obtiene estadísticas específicas para widgets
  VehicleStats? getVehicleStats() {
    if (_summary == null) return null;

    return VehicleStats(
      availableVehicles: _summary!.totalVehicles - _summary!.totalActiveRentals,
      rentedVehicles: _summary!.totalActiveRentals,
      inMaintenanceVehicles: 0, // Por ahora 0, se puede calcular después
      totalVehicles: _summary!.totalVehicles,
    );
  }

  /// Obtiene estadísticas de clientes
  ClientStats? getClientStats() {
    if (_summary == null) return null;

    final physicalClients = _clientsByType['fisica'] ?? 0;
    final corporateClients = _clientsByType['juridica'] ?? 0;

    return ClientStats(
      physicalClients: physicalClients,
      corporateClients: corporateClients,
      activeClients: _summary!.totalClients,
      totalClients: _summary!.totalClients,
    );
  }

  /// Limpia todos los datos
  void clearData() {
    _summary = null;
    _alerts.clear();
    _vehiclesByType.clear();
    _rentalsByMonth.clear();
    _clientsByType.clear();
    _error = null;
    notifyListeners();
  }
}
