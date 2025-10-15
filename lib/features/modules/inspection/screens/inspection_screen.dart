import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
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
    final vehicleProvider = context.watch<VehicleProvider>();
    final clientProvider = context.watch<ClientProvider>();
    final employeeProvider = context.watch<EmployeeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    // Crear mapas para obtener nombres en lugar de IDs
    final vehicleMap = {
      for (final vehicle in vehicleProvider.todosVehiculos)
        vehicle.id: '${vehicle.noPlaca} - ${vehicle.descripcion}',
    };
    final clientMap = {
      for (final client in clientProvider.todosClientes)
        client.id: '${client.cedula} - ${client.nombre}',
    };
    final employeeMap = {
      for (final employee in employeeProvider.todosEmpleados)
        employee.id: '${employee.cedula} - ${employee.nombre}',
    };

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Gestión de Inspecciones',
        isLoading: provider.isLoading,
        items: provider.inspecciones
            .map((inspeccion) => _buildInspectionItem(
                context,
                inspeccion,
                vehicleMap[inspeccion.vehiculo] ?? 'Vehículo ${inspeccion.vehiculo}',
                clientMap[inspeccion.cliente] ?? 'Cliente ${inspeccion.cliente}',
                employeeMap[inspeccion.empleadoInspeccion] ?? 'Empleado ${inspeccion.empleadoInspeccion}',
              ))
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
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEditing = initial != null;

    await showDialog(
      context: context,
      builder: (_) => GenericFormDialog<Inspection>(
        title: isEditing ? 'Editar Inspección' : 'Nueva Inspección',
        initialData: initial,
        onSubmit: (inspection) async {
          if (isEditing) {
            await context.read<InspectionProvider>().actualizarInspeccion(inspection);
          } else {
            await context.read<InspectionProvider>().agregarInspeccion(inspection);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing
                    ? 'Inspección actualizada exitosamente'
                    : 'Inspección creada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        fromValues: _mapToInspection,
        fields: [
          FormFieldDefinition<Inspection>(
            key: 'vehiculo',
            label: 'Vehículo',
            fieldType: 'dropdown',
            getValue: (inspection) => inspection?.vehiculo,
            applyValue: (inspection, value) => inspection,
            options: vehicleProvider.todosVehiculos
                .map((vehicle) => {
                      'value': vehicle.id,
                      'label': '${vehicle.noPlaca} - ${vehicle.descripcion}',
                    })
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Vehículo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'cliente',
            label: 'Cliente',
            fieldType: 'dropdown',
            getValue: (inspection) => inspection?.cliente,
            applyValue: (inspection, value) => inspection,
            options: clientProvider.todosClientes
                .map((client) => {
                      'value': client.id,
                      'label': '${client.cedula} - ${client.nombre}',
                    })
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Cliente es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'empleadoInspeccion',
            label: 'Empleado Inspector',
            fieldType: 'dropdown',
            getValue: (inspection) => inspection?.empleadoInspeccion,
            applyValue: (inspection, value) => inspection,
            options: employeeProvider.todosEmpleados
                .map((employee) => {
                      'value': employee.id,
                      'label': '${employee.cedula} - ${employee.nombre}',
                    })
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Empleado inspector es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'fecha',
            label: 'Fecha de Inspección',
            fieldType: 'date',
            getValue: (inspection) => inspection?.fecha ?? DateTime.now(),
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Fecha es requerida';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'cantidadCombustible',
            label: 'Cantidad de Combustible',
            fieldType: 'dropdown',
            getValue: (inspection) => inspection?.cantidadCombustible ?? CantidadCombustible.unCuarto,
            applyValue: (inspection, value) => inspection,
            options: const [
              {'value': CantidadCombustible.unCuarto, 'label': '1/4'},
              {'value': CantidadCombustible.medio, 'label': '1/2'},
              {'value': CantidadCombustible.tresCuartos, 'label': '3/4'},
              {'value': CantidadCombustible.lleno, 'label': 'Lleno'},
            ],
            validator: (value) {
              if (value == null) {
                return 'Cantidad de combustible es requerida';
              }
              return null;
            },
          ),
          // Campos Sí/No usando el nuevo tipo boolean
          FormFieldDefinition<Inspection>(
            key: 'tieneRalladuras',
            label: 'Tiene Ralladuras',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.tieneRalladuras,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneGomaRespuesta',
            label: 'Tiene Goma de Respuesta',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.tieneGomaRespuesta,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneGato',
            label: 'Tiene Gato',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.tieneGato,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'tieneRoturasCristal',
            label: 'Tiene Roturas en Cristal',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.tieneRoturasCristal,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          // Estados de gomas
          FormFieldDefinition<Inspection>(
            key: 'estadoGoma1',
            label: 'Estado de Goma 1 (Buen Estado)',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.estadoGoma1,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'estadoGoma2',
            label: 'Estado de Goma 2 (Buen Estado)',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.estadoGoma2,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'estadoGoma3',
            label: 'Estado de Goma 3 (Buen Estado)',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.estadoGoma3,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'estadoGoma4',
            label: 'Estado de Goma 4 (Buen Estado)',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.estadoGoma4,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
          FormFieldDefinition<Inspection>(
            key: 'estado',
            label: 'Inspección Activa',
            fieldType: 'boolean',
            getValue: (inspection) => inspection?.estado ?? true,
            applyValue: (inspection, value) => inspection,
            validator: (value) {
              if (value == null) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  CollectionItemData _buildInspectionItem(
    BuildContext context,
    Inspection inspeccion,
    String vehicleName,
    String clientName,
    String employeeName,
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
      subtitle: 'Vehículo: $vehicleName • Cliente: $clientName',
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
          value: vehicleName,
          inlineValue: 'Vehículo: $vehicleName',
          icon: Icons.directions_car_outlined,
        ),
        CollectionDetailInfo(
          label: 'Cliente',
          value: clientName,
          inlineValue: 'Cliente: $clientName',
          icon: Icons.person_outlined,
        ),
        CollectionDetailInfo(
          label: 'Inspector',
          value: employeeName,
          inlineValue: 'Inspector: $employeeName',
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

  // Helper method to convert form values to Inspection object
  Inspection _mapToInspection(Map<String, dynamic> values, Inspection? initial) {
    return Inspection(
      id: initial?.id ?? 0,
      vehiculo: values['vehiculo'] as int? ?? 0,
      cliente: values['cliente'] as int? ?? 0,
      tieneRalladuras: values['tieneRalladuras'] as bool? ?? false,
      cantidadCombustible: values['cantidadCombustible'] as CantidadCombustible? ?? CantidadCombustible.unCuarto,
      tieneGomaRespuesta: values['tieneGomaRespuesta'] as bool? ?? false,
      tieneGato: values['tieneGato'] as bool? ?? false,
      tieneRoturasCristal: values['tieneRoturasCristal'] as bool? ?? false,
      estadoGoma1: values['estadoGoma1'] as bool? ?? false,
      estadoGoma2: values['estadoGoma2'] as bool? ?? false,
      estadoGoma3: values['estadoGoma3'] as bool? ?? false,
      estadoGoma4: values['estadoGoma4'] as bool? ?? false,
      fecha: values['fecha'] as DateTime? ?? DateTime.now(),
      empleadoInspeccion: values['empleadoInspeccion'] as int? ?? 0,
      estado: values['estado'] as bool? ?? true,
    );
  }
}