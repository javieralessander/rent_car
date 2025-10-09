import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../../vehicles/providers/vehicle_provider.dart';
import '../../clients/providers/client_provider.dart';
import '../../employee/providers/employee_provider.dart';
import '../models/inspection_model.dart';
import '../providers/inspection_provider.dart';

class InspectionScreen extends StatefulWidget {
  static const String name = 'inspections';
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionProvider>().cargarInspecciones();
      context.read<VehicleProvider>().cargarVehiculos();
      context.read<ClientProvider>().cargarClientes();
      context.read<EmployeeProvider>().cargarEmpleados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectionProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Gestión de Inspecciones',
        isLoading: provider.isLoading,
        items: provider.inspecciones
            .map((inspeccion) => _buildInspectionItem(context, inspeccion))
            .toList(),
        viewMode: _viewMode,
        onViewModeChanged: (mode) => setState(() => _viewMode = mode),
        currentPage: provider.paginaActual,
        totalPages: provider.totalPaginas,
        totalItems: provider.totalRegistros,
        itemsPerPage: provider.registrosPorPagina,
        onPageChanged: provider.cambiarPagina,
        onItemsPerPageChanged: provider.cambiarRegistrosPorPagina,
        onSearch: (value) => provider.busqueda = value,
        topRightWidget: FloatingActionButton.extended(
          onPressed: () => _openInspectionDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva inspección'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
        emptyBuilder: provider.error != null
            ? Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _openInspectionDialog(
    BuildContext context, {
    Inspection? initial,
  }) async {
    final vehicleProvider = context.read<VehicleProvider>();
    final clientProvider = context.read<ClientProvider>();
    final employeeProvider = context.read<EmployeeProvider>();

    if (vehicleProvider.todosVehiculos.isEmpty ||
        clientProvider.todosClientes.isEmpty ||
        employeeProvider.todosEmpleados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifique que existan vehículos, clientes y empleados antes de continuar.'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => GenericFormDialog<Inspection>(
        title: initial == null ? 'Nueva Inspección' : 'Editar Inspección',
        initialData: initial,
        onSubmit: (data) async {
          if (initial == null) {
            await context.read<InspectionProvider>().agregarInspeccion(data);
          } else {
            await context.read<InspectionProvider>().actualizarInspeccion(data);
          }
        },
        fromValues: (values, previous) => Inspection(
          id: previous?.id ?? initial?.id ?? 0,
          vehiculo: values['vehiculo'] ?? previous?.vehiculo ?? initial?.vehiculo ?? vehicleProvider.todosVehiculos.first.id,
          cliente: values['cliente'] ?? previous?.cliente ?? initial?.cliente ?? clientProvider.todosClientes.first.id,
          tieneRalladuras: values['tieneRalladuras'] ?? previous?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
          cantidadCombustible: values['cantidadCombustible'] ?? previous?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
          tieneGomaRespuesta: values['tieneGomaRespuesta'] ?? previous?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
          tieneGato: values['tieneGato'] ?? previous?.tieneGato ?? initial?.tieneGato ?? false,
          tieneRoturasCristal: values['tieneRoturasCristal'] ?? previous?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
          estadoGoma1: values['estadoGoma1'] ?? previous?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
          estadoGoma2: values['estadoGoma2'] ?? previous?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
          estadoGoma3: values['estadoGoma3'] ?? previous?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
          estadoGoma4: values['estadoGoma4'] ?? previous?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
          fecha: values['fecha'] ?? previous?.fecha ?? initial?.fecha ?? DateTime.now(),
          empleadoInspeccion: values['empleadoInspeccion'] ?? previous?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? employeeProvider.todosEmpleados.first.id,
          estado: values['estado'] ?? previous?.estado ?? initial?.estado ?? true,
        ),
        fields: [
          FormFieldDefinition<Inspection>(
            key: 'vehiculo',
            label: 'Vehículo',
            fieldType: 'dropdown',
            options: vehicleProvider.todosVehiculos
                .map((vehicle) => {'value': vehicle.id, 'label': '${vehicle.numeroPlaca} - ${vehicle.descripcion}'})
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Vehículo es requerido';
              }
              return null;
            },
            getValue: (v) => v?.vehiculo ?? vehicleProvider.todosVehiculos.first.id,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: value as int,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'cliente',
            label: 'Cliente',
            fieldType: 'dropdown',
            options: clientProvider.todosClientes
                .map((client) => {'value': client.id, 'label': '${client.cedula} - ${client.nombre}'})
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Cliente es requerido';
              }
              return null;
            },
            getValue: (v) => v?.cliente ?? clientProvider.todosClientes.first.id,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: value as int,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'empleadoInspeccion',
            label: 'Empleado Inspector',
            fieldType: 'dropdown',
            options: employeeProvider.todosEmpleados
                .map((employee) => {'value': employee.id, 'label': '${employee.cedula} - ${employee.nombre}'})
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Empleado inspector es requerido';
              }
              return null;
            },
            getValue: (v) => v?.empleadoInspeccion ?? employeeProvider.todosEmpleados.first.id,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: value as int,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'fecha',
            label: 'Fecha de Inspección',
            fieldType: 'date',
            getValue: (v) => v?.fecha ?? DateTime.now(),
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: value as DateTime,
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'cantidadCombustible',
            label: 'Cantidad de Combustible',
            fieldType: 'dropdown',
            options: const [
              {'value': CantidadCombustible.unCuarto, 'label': '1/4'},
              {'value': CantidadCombustible.medio, 'label': '1/2'},
              {'value': CantidadCombustible.tresCuartos, 'label': '3/4'},
              {'value': CantidadCombustible.lleno, 'label': 'Lleno'},
            ],
            getValue: (v) => v?.cantidadCombustible ?? CantidadCombustible.unCuarto,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: value as CantidadCombustible,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneRalladuras',
            label: 'Tiene Ralladuras',
            fieldType: 'checkbox',
            getValue: (v) => v?.tieneRalladuras ?? false,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: value as bool,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneGomaRespuesta',
            label: 'Tiene Goma de Respuesta',
            fieldType: 'checkbox',
            getValue: (v) => v?.tieneGomaRespuesta ?? false,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: value as bool,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneGato',
            label: 'Tiene Gato',
            fieldType: 'checkbox',
            getValue: (v) => v?.tieneGato ?? false,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: value as bool,
              tieneRoturasCristal: v?.tieneRoturasCristal ?? initial?.tieneRoturasCristal ?? false,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneRoturasCristal',
            label: 'Tiene Roturas en Cristal',
            fieldType: 'checkbox',
            getValue: (v) => v?.tieneRoturasCristal ?? false,
            applyValue: (v, value) => Inspection(
              id: v?.id ?? initial?.id ?? 0,
              vehiculo: v?.vehiculo ?? initial?.vehiculo ?? 0,
              cliente: v?.cliente ?? initial?.cliente ?? 0,
              tieneRalladuras: v?.tieneRalladuras ?? initial?.tieneRalladuras ?? false,
              cantidadCombustible: v?.cantidadCombustible ?? initial?.cantidadCombustible ?? CantidadCombustible.unCuarto,
              tieneGomaRespuesta: v?.tieneGomaRespuesta ?? initial?.tieneGomaRespuesta ?? false,
              tieneGato: v?.tieneGato ?? initial?.tieneGato ?? false,
              tieneRoturasCristal: value as bool,
              estadoGoma1: v?.estadoGoma1 ?? initial?.estadoGoma1 ?? false,
              estadoGoma2: v?.estadoGoma2 ?? initial?.estadoGoma2 ?? false,
              estadoGoma3: v?.estadoGoma3 ?? initial?.estadoGoma3 ?? false,
              estadoGoma4: v?.estadoGoma4 ?? initial?.estadoGoma4 ?? false,
              fecha: v?.fecha ?? initial?.fecha ?? DateTime.now(),
              empleadoInspeccion: v?.empleadoInspeccion ?? initial?.empleadoInspeccion ?? 0,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
        ],
      ),
    );
  }

  CollectionItemData _buildInspectionItem(
    BuildContext context,
    Inspection inspeccion,
  ) {
    final isActive = inspeccion.estado;
    final hasIssues = inspeccion.tieneRalladuras ||
                      inspeccion.tieneRoturasCristal ||
                      !inspeccion.tieneGato ||
                      !inspeccion.tieneGomaRespuesta;

    return CollectionItemData(
      header: CollectionHeaderData(
        title: hasIssues ? 'Inspección con observaciones' : 'Inspección aprobada',
        subtitle: 'ID ${inspeccion.id}',
        backgroundColor: hasIssues ? AppColors.warning.withOpacity(0.05) : AppColors.success.withOpacity(0.05),
        leadingIcon: Icons.assignment_outlined,
      ),
      badge: CollectionBadgeData(text: 'I${inspeccion.id}'),
      title: 'Inspección #${inspeccion.id}',
      subtitle: 'Vehículo: ${inspeccion.vehiculo} • Cliente: ${inspeccion.cliente}',
      statusChip: CollectionStatusChip(
        label: hasIssues ? 'Con observaciones' : 'Aprobada',
        backgroundColor: hasIssues ? AppColors.warning.withOpacity(0.16) : AppColors.success.withOpacity(0.16),
        textColor: hasIssues ? AppColors.warning : AppColors.success,
      ),
      details: [
        CollectionDetailInfo(
          label: 'ID Inspección',
          value: '#${inspeccion.id}',
          inlineValue: 'ID ${inspeccion.id}',
          icon: Icons.confirmation_number_outlined,
        ),
        CollectionDetailInfo(
          label: 'Vehículo',
          value: 'ID ${inspeccion.vehiculo}',
          inlineValue: 'Vehículo: ${inspeccion.vehiculo}',
          icon: Icons.directions_car_outlined,
        ),
        CollectionDetailInfo(
          label: 'Cliente',
          value: 'ID ${inspeccion.cliente}',
          inlineValue: 'Cliente: ${inspeccion.cliente}',
          icon: Icons.person_outlined,
        ),
        CollectionDetailInfo(
          label: 'Inspector',
          value: 'ID ${inspeccion.empleadoInspeccion}',
          inlineValue: 'Inspector: ${inspeccion.empleadoInspeccion}',
          icon: Icons.badge_outlined,
        ),
        CollectionDetailInfo(
          label: 'Fecha',
          value: '${inspeccion.fecha.day}/${inspeccion.fecha.month}/${inspeccion.fecha.year}',
          inlineValue: 'Fecha: ${inspeccion.fecha.day}/${inspeccion.fecha.month}/${inspeccion.fecha.year}',
          icon: Icons.calendar_today_outlined,
        ),
        CollectionDetailInfo(
          label: 'Combustible',
          value: inspeccion.cantidadCombustibleString,
          inlineValue: 'Combustible: ${inspeccion.cantidadCombustibleString}',
          icon: Icons.local_gas_station_outlined,
        ),
        if (hasIssues)
          CollectionDetailInfo(
            label: 'Observaciones',
            value: _getObservaciones(inspeccion),
            inlineValue: _getObservaciones(inspeccion),
            icon: Icons.warning_outlined,
          ),
      ],
      actions: [
        CollectionActionData(
          label: 'Editar',
          icon: Icons.edit_outlined,
          variant: CollectionActionVariant.primary,
          onPressed: () => _openInspectionDialog(context, initial: inspeccion),
        ),
        CollectionActionData(
          label: 'Ver Detalles',
          icon: Icons.visibility_outlined,
          variant: CollectionActionVariant.secondary,
          onPressed: () => _showInspectionDetails(context, inspeccion),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => context.read<InspectionProvider>().eliminarInspeccion(inspeccion.id),
        ),
      ],
      footerStatus: CollectionFooterStatus(
        label: hasIssues ? 'Con observaciones' : 'Aprobada',
        color: hasIssues ? AppColors.warning : AppColors.success,
        icon: hasIssues ? Icons.warning : Icons.check_circle,
      ),
    );
  }

  String _getObservaciones(Inspection inspeccion) {
    List<String> observaciones = [];
    if (inspeccion.tieneRalladuras) observaciones.add('Ralladuras');
    if (inspeccion.tieneRoturasCristal) observaciones.add('Roturas cristal');
    if (!inspeccion.tieneGato) observaciones.add('Sin gato');
    if (!inspeccion.tieneGomaRespuesta) observaciones.add('Sin goma respuesta');

    return observaciones.isEmpty ? 'Ninguna' : observaciones.join(', ');
  }

  void _showInspectionDetails(BuildContext context, Inspection inspeccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Inspección #${inspeccion.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Vehículo:', 'ID ${inspeccion.vehiculo}'),
              _buildDetailRow('Cliente:', 'ID ${inspeccion.cliente}'),
              _buildDetailRow('Inspector:', 'ID ${inspeccion.empleadoInspeccion}'),
              _buildDetailRow('Fecha:', '${inspeccion.fecha.day}/${inspeccion.fecha.month}/${inspeccion.fecha.year}'),
              _buildDetailRow('Combustible:', inspeccion.cantidadCombustibleString),
              const Divider(),
              const Text('Verificaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCheckRow('Ralladuras:', inspeccion.tieneRalladuras),
              _buildCheckRow('Goma respuesta:', inspeccion.tieneGomaRespuesta),
              _buildCheckRow('Gato:', inspeccion.tieneGato),
              _buildCheckRow('Roturas cristal:', inspeccion.tieneRoturasCristal),
              const Divider(),
              const Text('Estado de Gomas:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCheckRow('Goma 1:', inspeccion.estadoGoma1),
              _buildCheckRow('Goma 2:', inspeccion.estadoGoma2),
              _buildCheckRow('Goma 3:', inspeccion.estadoGoma3),
              _buildCheckRow('Goma 4:', inspeccion.estadoGoma4),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AppColors.success : AppColors.danger,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(value ? 'Sí' : 'No'),
        ],
      ),
    );
  }
}