/// Modelos para datos del Dashboard RentCar
class DashboardSummary {
  final int totalVehicles;
  final int totalClients;
  final int totalActiveRentals;
  final int totalInspections;
  final double monthlyRevenue;
  final double averageRentalDuration;
  final int overdueRentals;
  final double vehicleUtilizationRate;
  final Map<String, int> vehiclesByType;
  final Map<String, int> rentalsByMonth;
  final Map<String, int> clientsByType;

  DashboardSummary({
    required this.totalVehicles,
    required this.totalClients,
    required this.totalActiveRentals,
    required this.totalInspections,
    required this.monthlyRevenue,
    required this.averageRentalDuration,
    required this.overdueRentals,
    required this.vehicleUtilizationRate,
    required this.vehiclesByType,
    required this.rentalsByMonth,
    required this.clientsByType,
  });

  factory DashboardSummary.empty() {
    return DashboardSummary(
      totalVehicles: 0,
      totalClients: 0,
      totalActiveRentals: 0,
      totalInspections: 0,
      monthlyRevenue: 0.0,
      averageRentalDuration: 0.0,
      overdueRentals: 0,
      vehicleUtilizationRate: 0.0,
      vehiclesByType: {},
      rentalsByMonth: {},
      clientsByType: {},
    );
  }
}

/// Datos para PieChart de rentas por tipo de vehículo
class VehicleTypePieData {
  final int sedans;
  final int suvs;
  final int trucks;
  final int vans;

  VehicleTypePieData({
    required this.sedans,
    required this.suvs,
    required this.trucks,
    required this.vans,
  });
}

/// Datos mensuales para BarChart de rentas
class MonthlyRentalData {
  final String month;
  final int rentals;
  final int returns;
  final double revenue;

  MonthlyRentalData({
    required this.month,
    required this.rentals,
    required this.returns,
    required this.revenue,
  });
}

/// Datos por estado para BarChart horizontal
class RentalStatusData {
  final String status;
  final int count;
  final double percentage;

  RentalStatusData({
    required this.status,
    required this.count,
    required this.percentage,
  });
}

/// Alertas del sistema RentCar
class RentCarAlert {
  final String type; // 'warning', 'error', 'info'
  final String message;
  final int count;
  final String actionLabel;
  final String actionRoute;

  RentCarAlert({
    required this.type,
    required this.message,
    required this.count,
    required this.actionLabel,
    required this.actionRoute,
  });
}

/// Estadísticas de clientes
class ClientStats {
  final int physicalClients;
  final int corporateClients;
  final int activeClients;
  final int totalClients;

  ClientStats({
    required this.physicalClients,
    required this.corporateClients,
    required this.activeClients,
    required this.totalClients,
  });
}

/// Estadísticas de vehículos
class VehicleStats {
  final int availableVehicles;
  final int rentedVehicles;
  final int inMaintenanceVehicles;
  final int totalVehicles;

  VehicleStats({
    required this.availableVehicles,
    required this.rentedVehicles,
    required this.inMaintenanceVehicles,
    required this.totalVehicles,
  });
}

/// Filtros para reportes de rentas
class RentalReportFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? vehicleType;
  final String? clientType;
  final String? status;
  final int? employeeId;

  RentalReportFilters({
    this.startDate,
    this.endDate,
    this.vehicleType,
    this.clientType,
    this.status,
    this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (startDate != null) 'startDate': startDate!.toIso8601String().split('T')[0],
      if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (clientType != null) 'clientType': clientType,
      if (status != null) 'status': status,
      if (employeeId != null) 'employeeId': employeeId,
    };
  }
}

/// Configuración de reporte
class ReportConfig {
  final String title;
  final String description;
  final bool includeCharts;
  final bool includeSummary;
  final List<String> columns;

  ReportConfig({
    required this.title,
    required this.description,
    this.includeCharts = true,
    this.includeSummary = true,
    required this.columns,
  });
}
