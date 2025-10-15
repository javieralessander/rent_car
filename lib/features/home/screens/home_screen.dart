import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_car/features/modules/vehicle_types/screens/vehicle_type_screen.dart';
import 'package:rent_car/features/modules/vehicles/screens/vehicle_screen.dart';
import 'package:rent_car/features/modules/clients/screens/client_screen.dart';
import 'package:rent_car/features/modules/rental/screens/rental_screen.dart';
import '../../../core/config/app_theme.dart';
import '../../../shared/widgets/generic_appbar.dart';
import '../widgets/bar_chart_sample7.dart';
import '../widgets/pie_chart_sample3.dart';
import '../widgets/bar_chart_sample4.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String name = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showAssistant = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos del dashboard al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton:
      //     isMobile || showAssistant
      //         ? null // Ocultar FAB en pantallas móviles
      //         : FloatingActionButton.extended(
      //           heroTag: 'chat_assistant',
      //           backgroundColor: Colors.blue,
      //           icon: const Icon(Icons.support_agent),
      //           label: const Text('Soporte'),
      //           onPressed: () => setState(() => showAssistant = true),
      //         ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            // CONTENIDO PRINCIPAL
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                return RefreshIndicator(
                  onRefresh: () => dashboardProvider.loadDashboardData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        // --------- ALERTAS EN FRANJA SUPERIOR ---------
                        _buildAlertsSection(dashboardProvider),

                        const SizedBox(height: 20),

                        // --------- INDICADORES DE CARGA O ERROR ---------
                        if (dashboardProvider.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (dashboardProvider.error != null)
                          _buildErrorSection(dashboardProvider)
                        else
                          // --------- GRÁFICOS PRINCIPALES ---------
                          _buildChartsSection(dashboardProvider, isMobile),

                        // --------- INFORMACIÓN ADICIONAL ---------
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              'Última actualización: ${_formatTime(DateTime.now())}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // PANEL LATERAL ASISTENTE/CHAT
            _buildAssistantPanel(sizeScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(DashboardProvider provider) {
    if (provider.alerts.isEmpty) return const SizedBox.shrink();

    final mainAlert = provider.alerts.first;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainAlert.message,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (mainAlert.count > 0)
                  Text(
                    '${mainAlert.count} elementos requieren atención',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.refreshSummary(),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }


  Widget _buildHorizontalQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildHorizontalQuickActionItem(
              icon: Icons.directions_car,
              label: 'Vehículos',
              color: AppColors.primary,
              onTap: () => context.pushReplacementNamed(VehicleScreen.name),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildHorizontalQuickActionItem(
              icon: Icons.people,
              label: 'Clientes',
              color: AppColors.secondary,
              onTap: () => context.pushReplacementNamed(ClientScreen.name),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildHorizontalQuickActionItem(
              icon: Icons.car_rental,
              label: 'Rentas',
              color: AppColors.success,
              onTap: () => context.pushReplacementNamed(RentalScreen.name),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildHorizontalQuickActionItem(
              icon: Icons.category,
              label: 'Tipos Vehículos',
              color: AppColors.info,
              onTap: () => context.pushReplacementNamed(VehicleTypeScreen.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(DashboardProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error cargando el dashboard',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadDashboardData(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(DashboardProvider provider, bool isMobile) {
    return Center(
      child: Wrap(
        spacing: isMobile ? 24 : 40,
        runSpacing: isMobile ? 24 : 40,
        alignment: WrapAlignment.center,
        children: [
          // Tarjeta PieChart con datos reales
          _buildPieChartCard(provider, isMobile),

          // Tarjeta BarChart vertical con datos reales
          _buildVerticalBarChartCard(provider, isMobile),

          // Tarjetas de métricas clave
          _buildMetricsCardsSection(provider, isMobile),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(DashboardProvider provider, bool isMobile) {
    final pieData =
        provider.vehiclesByType.isNotEmpty
            ? provider.vehiclesByType.entries
                .map(
                  (e) => PieChartSectionModel(
                    value: e.value.toDouble(),
                    title: _cleanVehicleTypeName(e.key),
                    color: _getColorForVehicleType(e.key),
                    iconData: _getIconForVehicleType(e.key),
                  ),
                )
                .toList()
            : [
              PieChartSectionModel(
                value: 5.0,
                title: 'Sedán',
                color: const Color(0xFF3B82F6),
                iconData: Icons.directions_car,
              ),
              PieChartSectionModel(
                value: 3.0,
                title: 'SUV',
                color: const Color(0xFF10B981),
                iconData: Icons.drive_eta,
              ),
              PieChartSectionModel(
                value: 2.0,
                title: 'Pickup',
                color: const Color(0xFFF59E0B),
                iconData: Icons.airport_shuttle,
              ),
            ];

    return Container(
      width: isMobile ? double.infinity : 420,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: isMobile ? 300 : 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Vehículos por Tipo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (provider.summary != null)
                  Chip(
                    label: Text(
                      '${provider.summary!.totalVehicles} total',
                    ),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: PieChartCustom(data: pieData)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBarChartCard(DashboardProvider provider, bool isMobile) {
    final barData =
        provider.rentalsByMonth.isNotEmpty
            ? provider.rentalsByMonth.entries
                .map(
                  (e) => CustomBarChartData(
                    stackedRods: [
                      [CustomRodStackItem(0, e.value.toDouble(), const Color(0xFF3B82F6))],
                    ],
                  ),
                )
                .toList()
            : [
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 5.0, const Color(0xFF3B82F6))],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 8.0, const Color(0xFF3B82F6))],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 12.0, const Color(0xFF3B82F6))],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 7.0, const Color(0xFF3B82F6))],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 9.0, const Color(0xFF3B82F6))],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 6.0, const Color(0xFF3B82F6))],
                ],
              ),
            ];

    final labels =
        provider.rentalsByMonth.isNotEmpty
            ? provider.rentalsByMonth.keys.toList()
            : ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    return Container(
      width: isMobile ? double.infinity : 520,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: isMobile ? 300 : 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rentas por Mes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (provider.summary != null)
                  Chip(
                    label: Text(
                      '${provider.summary!.totalActiveRentals} activas',
                    ),
                    backgroundColor: Colors.green.shade50,
                    avatar: const Icon(Icons.car_rental, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CustomBarChart(
                data: barData,
                bottomLabels: labels,
                gridColor: Colors.grey.shade300,
                maxY: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCardsSection(DashboardProvider provider, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 520,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Clientes',
                  value: '${provider.summary?.totalClients ?? 0}',
                  icon: Icons.people,
                  color: const Color(0xFF3B82F6),
                  subtitle: 'Registrados',
                ),
              ),
              SizedBox(width: isMobile ? 12 : 20),
              Expanded(
                child: _buildMetricCard(
                  title: 'Rentas Activas',
                  value: '${provider.summary?.totalActiveRentals ?? 0}',
                  icon: Icons.car_rental,
                  color: const Color(0xFF10B981),
                  subtitle: 'En curso',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Vehículos',
                  value: '${provider.summary?.totalVehicles ?? 0}',
                  icon: Icons.directions_car,
                  color: const Color(0xFFF59E0B),
                  subtitle: 'En flota',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Inspecciones',
                  value: '${provider.summary?.totalInspections ?? 0}',
                  icon: Icons.build_circle,
                  color: const Color(0xFF8B5CF6),
                  subtitle: 'Realizadas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantPanel(Size sizeScreen) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: 0,
      bottom: 0,
      right: showAssistant ? 0 : -350,
      width: 350,
      child: Material(
        elevation: 16,
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.support_agent, color: Colors.blue),
                title: const Text('Asistente de Soporte'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => showAssistant = false),
                ),
              ),
              const Divider(),
              const Expanded(
                child: Center(
                  child: Text(
                    'Aquí irá tu chat de soporte o asistente virtual.\nPuedes integrar mensajes, historial, etc.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea la hora de última actualización
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Obtiene color para tipos de vehículos
  Color _getColorForVehicleType(String type) {
    // Limpiar el tipo primero para comparar correctamente
    String cleanType = _cleanVehicleTypeName(type).toLowerCase();

    switch (cleanType) {
      case 'sedan':
      case 'sedán':
        return const Color(0xFF3B82F6); // Azul vibrante
      case 'suv':
        return const Color(0xFF10B981); // Verde esmeralda
      case 'camioneta':
      case 'pickup':
        return const Color(0xFFF59E0B); // Ámbar
      case 'compacto':
        return const Color(0xFF8B5CF6); // Púrpura
      case 'motocicleta':
        return const Color(0xFFEF4444); // Rojo
      case 'camión':
        return const Color(0xFF6B7280); // Gris
      default:
        // Generar colores diferentes para tipos no reconocidos
        return _generateColorFromString(cleanType);
    }
  }

  /// Genera un color único basado en el string
  Color _generateColorFromString(String text) {
    final colors = [
      const Color(0xFF3B82F6), // Azul
      const Color(0xFF10B981), // Verde
      const Color(0xFFF59E0B), // Ámbar
      const Color(0xFF8B5CF6), // Púrpura
      const Color(0xFFEF4444), // Rojo
      const Color(0xFF06B6D4), // Cian
      const Color(0xFFF97316), // Naranja
      const Color(0xFFEC4899), // Rosa
    ];

    int index = text.hashCode % colors.length;
    return colors[index.abs()];
  }

  /// Obtiene ícono para tipos de vehículos
  IconData _getIconForVehicleType(String type) {
    // Limpiar el tipo primero para comparar correctamente
    String cleanType = _cleanVehicleTypeName(type).toLowerCase();

    switch (cleanType) {
      case 'sedan':
      case 'sedán':
        return Icons.directions_car;
      case 'suv':
        return Icons.drive_eta;
      case 'camioneta':
      case 'pickup':
        return Icons.airport_shuttle;
      case 'compacto':
        return Icons.directions_car_filled;
      case 'motocicleta':
        return Icons.two_wheeler;
      case 'camión':
        return Icons.local_shipping;
      default:
        return Icons.directions_car_outlined;
    }
  }

  /// Limpia el nombre del tipo de vehículo
  String _cleanVehicleTypeName(String rawName) {
    // Remover "Tipo TipoVehiculo(" y otros prefijos
    String cleaned = rawName;

    // Remover patrones como "Tipo TipoVehiculo(22 - SUV)"
    if (cleaned.contains(' - ')) {
      cleaned = cleaned.split(' - ').last;
    }

    // Remover paréntesis y números
    cleaned = cleaned.replaceAll(RegExp(r'\([^)]*\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'Tipo\s*TipoVehiculo\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\d+\s*-\s*'), '');

    // Remover paréntesis finales sueltos
    cleaned = cleaned.replaceAll(RegExp(r'\)+$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\(+$'), '');

    return cleaned.trim();
  }
}
