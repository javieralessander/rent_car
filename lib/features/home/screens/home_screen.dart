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
      floatingActionButton:
          isMobile || showAssistant
              ? null // Ocultar FAB en pantallas móviles
              : FloatingActionButton.extended(
                heroTag: 'chat_assistant',
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.support_agent),
                label: const Text('Soporte'),
                onPressed: () => setState(() => showAssistant = true),
              ),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // --------- ALERTAS EN FRANJA SUPERIOR ---------
                        _buildAlertsSection(dashboardProvider),

                        // --------- ACCESOS RÁPIDOS ---------
                        _buildQuickActionsSection(),

                        const SizedBox(height: 24),

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
                          padding: const EdgeInsets.only(top: 24),
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

  Widget _buildQuickActionsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
       
        ElevatedButton.icon(
          icon: const Icon(Icons.directions_car),
          label: const Text('Vehículos'),
          onPressed: () {
            context.pushReplacementNamed(VehicleScreen.name);
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.category),
          label: const Text('Tipos Vehículos'),
          onPressed: () {
            context.pushReplacementNamed(VehicleTypeScreen.name);
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.people),
          label: const Text('Clientes'),
          onPressed: () {
            context.pushReplacementNamed(ClientScreen.name);
          },
        ),
      ],
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
        spacing: 32,
        runSpacing: 32,
        alignment: WrapAlignment.center,
        children: [
          // Tarjeta PieChart con datos reales
          _buildPieChartCard(provider, isMobile),

          // Tarjeta BarChart vertical con datos reales
          _buildVerticalBarChartCard(provider, isMobile),

          // Tarjeta BarChart horizontal con datos reales
          _buildHorizontalBarChartCard(provider, isMobile),
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
                    title: e.key,
                    color: _getColorForVehicleType(e.key),
                    svgAsset: 'assets/svgs/sicom.svg',
                  ),
                )
                .toList()
            : [
              PieChartSectionModel(
                value: 5.0,
                title: 'Sedán',
                color: Colors.blue,
                svgAsset: 'assets/svgs/sicom.svg',
              ),
              PieChartSectionModel(
                value: 3.0,
                title: 'SUV',
                color: Colors.green,
                svgAsset: 'assets/svgs/sicom.svg',
              ),
              PieChartSectionModel(
                value: 2.0,
                title: 'Camioneta',
                color: Colors.orange,
                svgAsset: 'assets/svgs/sicom.svg',
              ),
            ];

    return Container(
      width: isMobile ? double.infinity : 400,
      padding: const EdgeInsets.all(24),
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
                  'Vehículos por Tipo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (provider.summary != null) ...[
                      Chip(
                        label: Text(
                          '${provider.summary!.clientsByType} vehículos',
                        ),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${provider.summary!.totalActiveRentals} rentados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                      [CustomRodStackItem(0, e.value.toDouble(), Colors.blue)],
                    ],
                  ),
                )
                .toList()
            : [
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 5.0, Colors.blue)],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 8.0, Colors.blue)],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 12.0, Colors.blue)],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 7.0, Colors.blue)],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 9.0, Colors.blue)],
                ],
              ),
              CustomBarChartData(
                stackedRods: [
                  [CustomRodStackItem(0, 6.0, Colors.blue)],
                ],
              ),
            ];

    final labels =
        provider.rentalsByMonth.isNotEmpty
            ? provider.rentalsByMonth.keys.toList()
            : ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    return Container(
      width: isMobile ? double.infinity : 500,
      padding: const EdgeInsets.all(24),
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

  Widget _buildHorizontalBarChartCard(
    DashboardProvider provider,
    bool isMobile,
  ) {
    final statusData =
        provider.clientsByType.isNotEmpty
            ? provider.clientsByType.entries
                .map(
                  (e) => BarData(
                    e.key == 'fisica' ? Colors.blue : Colors.green,
                    e.value.toDouble(),
                    e.value.toDouble() + 2, // shadowValue
                  ),
                )
                .toList()
            : [
              const BarData(Colors.blue, 8.0, 10.0),
              const BarData(Colors.green, 4.0, 6.0),
            ];

    return Container(
      width: isMobile ? double.infinity : 500,
      padding: const EdgeInsets.all(24),
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
                  'Clientes por Tipo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (provider.summary != null)
                  Chip(
                    label: Text('${provider.summary!.totalClients} clientes'),
                    backgroundColor: Colors.orange.shade50,
                    avatar: const Icon(Icons.people, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BarChartSample7(
                dataList: statusData,
                title: '',
                maxY: 20,
                shadowColor: AppColors.borderColor,
              ),
            ),
          ],
        ),
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
    switch (type.toLowerCase()) {
      case 'sedan':
      case 'sedán':
        return Colors.blue;
      case 'suv':
        return Colors.green;
      case 'camioneta':
      case 'pickup':
        return Colors.orange;
      case 'compacto':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
