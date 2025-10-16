import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../../vehicles/providers/vehicle_provider.dart';
import '../../vehicles/models/vehicle_model.dart';
import '../../clients/providers/client_provider.dart';
import '../../employee/providers/employee_provider.dart';
import '../models/rental_model.dart';
import '../models/rental_form.dart';
import '../providers/rental_provider.dart';
import '../services/rental_report_service.dart';

class RentalScreen extends StatefulWidget {
  static const String name = 'rentals';
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalProvider>().cargarRentas();
      context.read<VehicleProvider>().cargarVehiculos();
      context.read<ClientProvider>().cargarClientes();
      context.read<EmployeeProvider>().cargarEmpleados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    final clientProvider = context.watch<ClientProvider>();
    final employeeProvider = context.watch<EmployeeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;


    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Gestión de Rentas',
        isLoading: provider.isLoading,
        items: provider.rentas
            .map((renta) => _buildRentalItem(
                context,
                renta,
                renta.vehiculo != null ? '${renta.vehiculo!.noPlaca} - ${renta.vehiculo!.descripcion}' : 'Sin vehículo',
                renta.cliente != null ? '${renta.cliente!.cedula} - ${renta.cliente!.nombre}' : 'Sin cliente',
                renta.empleado != null ? '${renta.empleado!.cedula} - ${renta.empleado!.nombre}' : 'Sin empleado',
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
        topRightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _showReportDialog(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              onPressed: () => _openRentalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva renta'),
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
          ],
        ),
        emptyBuilder: provider.error != null
            ? Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                  if (provider.error!.contains('No se puede conectar al servidor'))
                    ...[
                      const SizedBox(height: 16),
                      Card(
                        color: AppColors.warning.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, color: AppColors.warning),
                                  SizedBox(width: 8),
                                  Text(
                                    'Soluciones posibles:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '1. Verifique que el servidor backend Spring Boot esté ejecutándose\n'
                                '2. Confirme que esté corriendo en el puerto 8080\n'
                                '3. Revise la configuración de CORS en el backend\n'
                                '4. Verifique la URL en .env.development',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => provider.cargarRentas(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar conexión'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _openRentalDialog(
    BuildContext context, {
    Rental? initial,
  }) async {
    final vehicleProvider = context.read<VehicleProvider>();
    final clientProvider = context.read<ClientProvider>();
    final employeeProvider = context.read<EmployeeProvider>();

    final rentalProvider = context.read<RentalProvider>();
    final availableVehicles = _getAvailableVehicles(vehicleProvider, rentalProvider, initial);

    // Verificar que existan datos básicos
    if (vehicleProvider.todosVehiculos.isEmpty ||
        clientProvider.todosClientes.isEmpty ||
        employeeProvider.todosEmpleados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vehicleProvider.todosVehiculos.isEmpty
              ? 'No hay vehículos registrados. Primero debe registrar vehículos.'
              : clientProvider.todosClientes.isEmpty
                ? 'No hay clientes registrados. Primero debe registrar clientes.'
                : 'No hay empleados registrados. Primero debe registrar empleados.'
          ),
        ),
      );
      return;
    }

    // Verificar vehículos disponibles solo si hay vehículos pero ninguno disponible
    if (availableVehicles.isEmpty && vehicleProvider.todosVehiculos.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay vehículos disponibles para rentar. Todos están actualmente rentados.'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => GenericFormDialog<RentalForm>(
        title: initial == null ? 'Nueva Renta' : 'Editar Renta',
        initialData: initial != null ? RentalForm.fromRental(initial) : null,
        onSubmit: (rentalForm) async {
          // Validación cross-field antes de enviar
          if (rentalForm.fechaDevolucion != null) {
            final error = InputValidators.dateAfterOrEqual(
              rentalForm.fechaDevolucion,
              rentalForm.fechaRenta,
              targetFieldName: 'Fecha de devolución',
              referenceFieldName: 'fecha de renta',
            );
            if (error != null) {
              throw Exception(error);
            }
          }

          if (initial == null) {
            // Para crear: usar el método optimizado que envía solo IDs
            await context.read<RentalProvider>().agregarRentaFromForm(rentalForm);
          } else {
            // Para actualizar: construir Rental completo como antes
            final empleado = employeeProvider.todosEmpleados.firstWhere(
              (e) => e.id == rentalForm.empleadoId,
              orElse: () => employeeProvider.todosEmpleados.first,
            );
            final vehiculo = vehicleProvider.todosVehiculos.firstWhere(
              (v) => v.id == rentalForm.vehiculoId,
              orElse: () => vehicleProvider.todosVehiculos.first,
            );
            final cliente = clientProvider.todosClientes.firstWhere(
              (c) => c.id == rentalForm.clienteId,
              orElse: () => clientProvider.todosClientes.first,
            );

            final rental = rentalForm.toRental(
              empleado: empleado,
              vehiculo: vehiculo,
              cliente: cliente,
            );

            await context.read<RentalProvider>().actualizarRenta(rental);
          }
        },
        fromValues: (values, previous) => RentalForm(
          noRenta: previous?.noRenta ?? (initial != null ? RentalForm.fromRental(initial).noRenta : null),
          empleadoId: values['empleadoId'] ?? previous?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : employeeProvider.todosEmpleados.first.id!),
          vehiculoId: values['vehiculoId'] ?? previous?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : _getAvailableVehicles(vehicleProvider, context.read<RentalProvider>(), initial).first.id!),
          clienteId: values['clienteId'] ?? previous?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : clientProvider.todosClientes.first.id!),
          fechaRenta: values['fechaRenta'] ?? previous?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
          fechaDevolucion: values['fechaDevolucion'] ?? previous?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
          montoDia: (() {
            final val = values['montoDia'];
            if (val is double) return val;
            if (val is int) return val.toDouble();
            if (val is String) return double.tryParse(val) ?? 0.0;
            return previous?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0);
          })(),
          cantidadDias: values['cantidadDias'] ?? previous?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
          comentario: values['comentario'] ?? previous?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
          estado: (() {
            final val = values['estado'];
            if (val is EstadoRenta) return val;
            if (val is bool) return val ? EstadoRenta.ACTIVA : EstadoRenta.DEVUELTA;
            return previous?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA);
          })(),
        ),
        fields: [
          FormFieldDefinition<RentalForm>(
            key: 'empleadoId',
            label: 'Empleado',
            fieldType: 'dropdown',
            options: employeeProvider.todosEmpleados
                .map((employee) => {'value': employee.id, 'label': '${employee.cedula} - ${employee.nombre}'})
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Empleado es requerido';
              }
              return null;
            },
            getValue: (v) => v?.empleadoId,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: value as int,
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'vehiculoId',
            label: 'Vehículo',
            fieldType: 'dropdown',
            options: _getAvailableVehicles(vehicleProvider, context.read<RentalProvider>(), initial)
                .map((vehicle) => {'value': vehicle.id, 'label': '${vehicle.noPlaca} - ${vehicle.descripcion}'})
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Vehículo es requerido';
              }
              return null;
            },
            getValue: (v) => v?.vehiculoId,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: value as int,
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'clienteId',
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
            getValue: (v) => v?.clienteId,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: value as int,
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'fechaRenta',
            label: 'Fecha de Renta',
            fieldType: 'date',
            getValue: (v) => v?.fechaRenta,
            validator: (value) {
              if (value == null) return 'La fecha de renta es requerida';
              // Permitir fechas futuras para rentas
              return null;
            },
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: value as DateTime,
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'fechaDevolucion',
            label: 'Fecha de devolución',
            fieldType: 'custom',
            builder: (context, controller, initialData, formValues) {
              // Validación cross-field que se evalúa en cada rebuild
              final currentDate = controller.value as DateTime?;
              final fechaRenta = formValues?['fechaRenta'] as DateTime?;
              String? errorMessage;

              if (currentDate != null && fechaRenta != null) {
                errorMessage = InputValidators.dateAfterOrEqual(
                  currentDate,
                  fechaRenta,
                  targetFieldName: 'Fecha de devolución',
                  referenceFieldName: 'fecha de renta',
                );
              }

              return TextFormField(
                key: Key('fechaDevolucion_${fechaRenta?.millisecondsSinceEpoch}_${currentDate?.millisecondsSinceEpoch}'),
                decoration: InputDecoration(
                  labelText: 'Fecha de devolución',
                  suffixIcon: const Icon(Icons.calendar_today),
                  errorText: errorMessage,
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: controller.value != null
                    ? '${(controller.value as DateTime).year.toString().padLeft(4, '0')}-${(controller.value as DateTime).month.toString().padLeft(2, '0')}-${(controller.value as DateTime).day.toString().padLeft(2, '0')}'
                    : '',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.value as DateTime? ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    controller.setValue(date);
                  }
                },
                validator: (value) {
                  // Solo para validación de formulario, no mostramos mensaje aquí
                  return null;
                },
              );
            },
            getValue: (v) => v?.fechaDevolucion,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: value as DateTime?,
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'montoDia',
            label: 'Monto por día',
            fieldType: 'decimal',
            textValidator: (value) => InputValidators.requiredDecimal(
              value,
              fieldName: 'Monto por día',
              minValue: 0.01,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]{0,2}')),
              // Solo permite números positivos y hasta dos decimales
            ],
            getValue: (v) => v?.montoDia,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: (() {
                if (value is double) return value;
                if (value is int) return value.toDouble();
                if (value is String) return double.tryParse(value) ?? 0.0;
                return v?.montoDia ?? initial?.montoDia ?? 0.0;
              })(),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'cantidadDias',
            label: 'Cantidad de días',
            fieldType: 'number',
            textValidator: (value) => InputValidators.requiredNumber(
              value,
              fieldName: 'Cantidad de días',
              minValue: 1,
            ),
            getValue: (v) => v?.cantidadDias,
            inputFormatters: InputFormatters.digitsOnly(),
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: value as int,
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'comentario',
            label: 'Comentario',
            getValue: (v) => v?.comentario,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: value as String,
              estado: v?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
            ),
          ),
          FormFieldDefinition<RentalForm>(
            key: 'estado',
            label: 'Estado',
            fieldType: 'dropdown',
            options: const [
              {'value': EstadoRenta.RESERVADA, 'label': 'Reservada'},
              {'value': EstadoRenta.ACTIVA, 'label': 'En renta'},
              {'value': EstadoRenta.DEVUELTA, 'label': 'Devuelta'},
              {'value': EstadoRenta.VENCIDA, 'label': 'Vencida'},
              {'value': EstadoRenta.CANCELADA, 'label': 'Cancelada'},
              {'value': EstadoRenta.PERDIDA, 'label': 'Perdida'},
            ],
            getValue: (v) => v?.estado,
            applyValue: (v, value) => RentalForm(
              noRenta: v?.noRenta ?? initial?.noRenta,
              empleadoId: v?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : 0),
              vehiculoId: v?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : 0),
              clienteId: v?.clienteId ?? (initial != null ? RentalForm.fromRental(initial).clienteId : 0),
              fechaRenta: v?.fechaRenta ?? (initial != null ? RentalForm.fromRental(initial).fechaRenta : DateTime.now()),
              fechaDevolucion: v?.fechaDevolucion ?? (initial != null ? RentalForm.fromRental(initial).fechaDevolucion : null),
              montoDia: v?.montoDia ?? (initial != null ? RentalForm.fromRental(initial).montoDia : 0.0),
              cantidadDias: v?.cantidadDias ?? (initial != null ? RentalForm.fromRental(initial).cantidadDias : 1),
              comentario: v?.comentario ?? (initial != null ? RentalForm.fromRental(initial).comentario : ''),
              estado: value as EstadoRenta,
            ),
          ),
        ],
      ),
    );
  }

  CollectionItemData _buildRentalItem(
    BuildContext context,
    Rental renta,
    String vehicleName,
    String clientName,
    String employeeName,
  ) {
    final isDevuelto = renta.esDevuelto;
    final montoTotal = renta.montoTotal;

    return CollectionItemData(
      header: CollectionHeaderData(
        title: isDevuelto ? 'Renta devuelta' : 'Renta activa',
        subtitle: 'No. ${renta.noRenta}',
        backgroundColor: AppColors.primary.withOpacity(0.05),
        leadingIcon: Icons.car_rental_outlined,
      ),
      badge: CollectionBadgeData(text: 'R${renta.noRenta}'),
      title: 'Renta #${renta.noRenta}',
      subtitle: 'Cliente: $clientName • Vehículo: $vehicleName',
      statusChip: CollectionStatusChip(
        label: renta.estadoDescripcion,
        backgroundColor: _getColorFromString(renta.estadoColor).withOpacity(0.16),
        textColor: _getColorFromString(renta.estadoColor),
      ),
      details: [
        CollectionDetailInfo(
          label: 'No. Renta',
          value: '#${renta.noRenta}',
          inlineValue: 'No. ${renta.noRenta}',
          icon: Icons.confirmation_number_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Cliente',
          value: clientName,
          inlineValue: clientName.length > 20 ? '${clientName.substring(0, 20)}...' : clientName,
          icon: Icons.person_outlined,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primary.withOpacity(0.15),
        ),
        CollectionDetailInfo(
          label: 'Vehículo',
          value: vehicleName,
          inlineValue: vehicleName.length > 20 ? '${vehicleName.substring(0, 20)}...' : vehicleName,
          icon: Icons.directions_car_outlined,
          iconColor: AppColors.secondary,
          iconBackground: AppColors.secondary.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Fecha',
          value: '${renta.fechaRenta.day}/${renta.fechaRenta.month}/${renta.fechaRenta.year}',
          inlineValue: '${renta.fechaRenta.day}/${renta.fechaRenta.month}/${renta.fechaRenta.year}',
          icon: Icons.calendar_today_outlined,
          iconColor: AppColors.success,
          iconBackground: AppColors.success.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Total',
          value: InputFormatters.formatCurrency(montoTotal),
          inlineValue: InputFormatters.formatCurrency(montoTotal),
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primary.withOpacity(0.14),
        ),
      ],
      actions: [
        CollectionActionData(
          label: 'Editar',
          icon: Icons.edit_outlined,
          variant: CollectionActionVariant.primary,
          onPressed: () => _openRentalDialog(context, initial: renta),
        ),
        // Botón "Devolver" para rentas sin fecha de devolución (fecha programada pasada/actual)
        if (!isDevuelto && renta.fechaDevolucion == null)
          CollectionActionData(
            label: 'Devolver',
            icon: Icons.assignment_return_outlined,
            variant: CollectionActionVariant.secondary,
            onPressed: () => _devolverRenta(context, renta),
          ),
        // Botón "Recibir" para rentas con fecha futura (devolución anticipada)
        if (renta.necesitaRecibir)
          CollectionActionData(
            label: 'Recibir',
            icon: Icons.check_circle_outline,
            variant: CollectionActionVariant.primary,
            onPressed: () => _recibirVehiculo(context, renta),
          ),
        // Botón temporal para corregir rentas inconsistentes
        if (renta.estado == EstadoRenta.DEVUELTA && renta.fechaDevolucion == null)
          CollectionActionData(
            label: 'Corregir',
            icon: Icons.build_outlined,
            variant: CollectionActionVariant.outlined,
            onPressed: () => _corregirRentaInconsistente(context, renta),
          ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => _eliminarRenta(context, renta),
        ),
      ],
      footerStatus: CollectionFooterStatus(
        label: renta.necesitaRecibir ? 'Pendiente recibo' : renta.estadoDescripcion,
        color: renta.necesitaRecibir ? AppColors.warning : _getColorFromString(renta.estadoColor),
        icon: _getIconFromState(renta, renta.necesitaRecibir),
      ),
    );
  }

  List<Vehicle> _getAvailableVehicles(VehicleProvider vehicleProvider, RentalProvider rentalProvider, Rental? initial) {
    // Si no hay rentas registradas, todos los vehículos están disponibles
    if (rentalProvider.todasRentas.isEmpty) {
      debugPrint('=== Sin rentas registradas: todos los vehículos disponibles ===');
      return vehicleProvider.todosVehiculos;
    }

    // Obtener vehículos actualmente rentados
    // Un vehículo NO está disponible si:
    // 1. Hay una renta que NO está devuelta (fechaDevolucion == null)
    // 2. Y esa renta NO está cancelada (estado != CANCELADA)
    final vehiculosRentados = rentalProvider.todasRentas
        .where((renta) {
          // Un vehículo NO está disponible si:
          // 1. La renta está activa (no cancelada)
          // 2. Y NO ha sido realmente devuelta (esDevuelto considera fecha actual)
          final estaCancelada = renta.estado == EstadoRenta.CANCELADA;
          final estaRealmenteDevuelta = renta.esDevuelto; // Usa la lógica mejorada

          // El vehículo está rentado si NO está cancelada Y NO está realmente devuelta
          return !estaCancelada && !estaRealmenteDevuelta;
        })
        .map((renta) => renta.vehiculo?.id)
        .where((id) => id != null)
        .toSet();

    // Si estamos editando una renta, incluir el vehículo actual
    final vehiculoActualId = initial?.vehiculo?.id;

    // Debug: Imprimir información para diagnosticar
    debugPrint('=== DEBUG FILTRADO VEHÍCULOS ===');
    debugPrint('Total rentas: ${rentalProvider.todasRentas.length}');
    for (final renta in rentalProvider.todasRentas) {
      final estaCancelada = renta.estado == EstadoRenta.CANCELADA;
      final estaRealmenteDevuelta = renta.esDevuelto;
      final necesitaRecibir = renta.necesitaRecibir;
      final estaEnUso = !estaCancelada && !estaRealmenteDevuelta;
      debugPrint('Renta ${renta.noRenta}: Estado=${renta.estado}, FechaDevolucion=${renta.fechaDevolucion}, VehiculoId=${renta.vehiculo?.id}, RealmenteDevuelta=$estaRealmenteDevuelta, NecesitaRecibir=$necesitaRecibir, EnUso=$estaEnUso');
    }
    debugPrint('Vehículos rentados (IDs): $vehiculosRentados');
    debugPrint('Total vehículos disponibles filtrados: ${vehicleProvider.todosVehiculos.where((v) => !vehiculosRentados.contains(v.id)).length}');
    debugPrint('================================');

    return vehicleProvider.todosVehiculos.where((vehiculo) {
      // Incluir vehículos que no están rentados
      if (!vehiculosRentados.contains(vehiculo.id)) return true;

      // Si estamos editando, incluir el vehículo actual de esta renta
      if (vehiculoActualId != null && vehiculo.id == vehiculoActualId) return true;

      return false;
    }).toList();
  }

  Future<void> _devolverRenta(BuildContext context, Rental renta) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devolver Vehículo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Confirma la devolución del vehículo ${renta.vehiculo?.noPlaca} de la renta #${renta.noRenta}?'),
            const SizedBox(height: 8),
            const Text(
              'Esto marcará la renta como devuelta con la fecha y hora actual.',
              style: TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
            child: const Text('Devolver'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<RentalProvider>().devolverVehiculo(renta.noRenta!, DateTime.now());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo devuelto exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al devolver vehículo: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarRenta(BuildContext context, Rental renta) async {
    await ConfirmationDialog.showDeleteDialog(
      context: context,
      title: 'Eliminar Renta',
      itemName: 'Renta #${renta.noRenta}',
      additionalInfo: 'Se eliminará permanentemente del sistema.',
      onConfirm: () async {
        try {
          await context.read<RentalProvider>().eliminarRenta(renta.noRenta!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Renta eliminada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar renta: $e'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _recibirVehiculo(BuildContext context, Rental renta) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recibir Vehículo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Confirma que está recibiendo el vehículo ${renta.vehiculo?.noPlaca} de la renta #${renta.noRenta}?'),
            const SizedBox(height: 8),
            if (renta.fechaDevolucion != null)
              Text(
                'Fecha programada: ${renta.fechaDevolucion!.day}/${renta.fechaDevolucion!.month}/${renta.fechaDevolucion!.year}',
                style: const TextStyle(fontSize: 12, color: AppColors.grayDark),
              ),
            const SizedBox(height: 8),
            const Text(
              'Esto marcará la renta como devuelta con la fecha y hora actual.',
              style: TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
            child: const Text('Recibir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<RentalProvider>().recibirVehiculo(renta.noRenta!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo recibido exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al recibir vehículo: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _corregirRentaInconsistente(BuildContext context, Rental renta) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corregir Renta Inconsistente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('La renta #${renta.noRenta} tiene estado "DEVUELTA" pero no tiene fecha de devolución registrada.'),
            const SizedBox(height: 8),
            const Text('¿Desea corregir esto estableciendo la fecha de devolución actual?'),
            const SizedBox(height: 8),
            const Text('Nota: Esta es una solución temporal para resolver inconsistencias de datos.',
              style: TextStyle(fontSize: 12, color: AppColors.warning)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Corregir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        context.read<RentalProvider>().marcarComoDevuelta(renta.noRenta!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Renta corregida exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al corregir renta: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  /// Convierte string de color a Color de AppColors
  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'info':
        return AppColors.info;
      case 'success':
        return AppColors.success;
      case 'primary':
        return AppColors.primary;
      case 'warning':
        return AppColors.warning;
      case 'danger':
        return AppColors.danger;
      default:
        return AppColors.grayDark;
    }
  }

  /// Obtiene el ícono apropiado basado en el estado de la renta
  IconData _getIconFromState(Rental renta, bool necesitaRecibir) {
    if (necesitaRecibir) return Icons.schedule;

    switch (renta.estadoCalculado) {
      case EstadoRenta.RESERVADA:
        return Icons.event_available;      // Calendario disponible
      case EstadoRenta.ACTIVA:
        return Icons.drive_eta;           // Auto en uso
      case EstadoRenta.DEVUELTA:
        return Icons.assignment_return;   // Devuelto
      case EstadoRenta.VENCIDA:
        return Icons.warning;             // Advertencia
      case EstadoRenta.CANCELADA:
        return Icons.cancel;              // Cancelado
      case EstadoRenta.PERDIDA:
        return Icons.error;               // Error/perdido
    }
  }

  void _showReportDialog(BuildContext context) {
    final vehicleProvider = context.read<VehicleProvider>();
    final rentalProvider = context.read<RentalProvider>();

    showDialog(
      context: context,
      builder: (context) => _RentalReportDialog(
        vehicleProvider: vehicleProvider,
        rentalProvider: rentalProvider,
      ),
    );
  }
}

class _RentalReportDialog extends StatefulWidget {
  final VehicleProvider vehicleProvider;
  final RentalProvider rentalProvider;

  const _RentalReportDialog({
    required this.vehicleProvider,
    required this.rentalProvider,
  });

  @override
  _RentalReportDialogState createState() => _RentalReportDialogState();
}

class _RentalReportDialogState extends State<_RentalReportDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedVehicleType;
  String? _selectedStatus;
  bool _includeCharts = true;
  bool _includeSummary = true;
  String? _dateValidationError;

  // Obtener tipos de vehículos dinámicamente
  List<String> get _vehicleTypes {
    final types = widget.vehicleProvider.todosVehiculos
        .where((vehicle) => vehicle.tipoVehiculo != null)
        .map((vehicle) => vehicle.tipoVehiculo!.descripcion)
        .toSet() // Remover duplicados
        .toList();
    types.sort(); // Ordenar alfabéticamente
    return types;
  }

  // Estados de renta con etiquetas amigables
  final Map<String, String> _statusLabels = {
    'ACTIVA': 'En renta',
    'DEVUELTA': 'Devuelta',
    'VENCIDA': 'Vencida',
    'CANCELADA': 'Cancelada',
    'RESERVADA': 'Reservada',
    'PERDIDA': 'Perdida',
  };

  @override
  void initState() {
    super.initState();
    // Validar selecciones al inicializar
    _validateSelections();
  }

  // Validar que las selecciones actuales sigan siendo válidas
  void _validateSelections() {
    // Validar tipo de vehículo
    if (_selectedVehicleType != null && !_vehicleTypes.contains(_selectedVehicleType)) {
      _selectedVehicleType = null;
    }

    // Validar estado
    if (_selectedStatus != null && !_statusLabels.containsKey(_selectedStatus)) {
      _selectedStatus = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Generar reporte PDF'),
        ],
      ),
      content: Container(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuración del Reporte',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 16),

              // Fechas
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha Inicio',
                          border: OutlineInputBorder(),
                          errorText: _dateValidationError != null && _dateValidationError!.contains('inicio') ? _dateValidationError : null,
                        ),
                        child: Text(_startDate?.toString().split(' ')[0] ?? 'Seleccionar'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha Fin',
                          border: OutlineInputBorder(),
                          errorText: _dateValidationError != null && _dateValidationError!.contains('fin') ? _dateValidationError : null,
                        ),
                        child: Text(_endDate?.toString().split(' ')[0] ?? 'Seleccionar'),
                      ),
                    ),
                  ),
                ],
              ),
              if (_dateValidationError != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateValidationError!,
                          style: TextStyle(color: AppColors.danger, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),

              // Filtros
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Vehículo',
                  border: OutlineInputBorder(),
                ),
                value: _selectedVehicleType,
                items: [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  ..._vehicleTypes.map((type) =>
                    DropdownMenuItem(value: type, child: Text(type))),
                ],
                onChanged: (value) => setState(() => _selectedVehicleType = value),
              ),
              SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Estado de Renta',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStatus,
                items: [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  ..._statusLabels.entries.map((entry) =>
                    DropdownMenuItem(value: entry.key, child: Text(entry.value))),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value),
              ),
              SizedBox(height: 16),

              // Opciones
              Text('Opciones del Reporte',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Incluir gráficos'),
                value: _includeCharts,
                onChanged: (value) => setState(() => _includeCharts = value ?? true),
              ),
              CheckboxListTile(
                title: Text('Incluir resumen estadístico'),
                value: _includeSummary,
                onChanged: (value) => setState(() => _includeSummary = value ?? true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () => _generateReport(context),
          icon: Icon(Icons.download),
          label: Text('Generar PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          // Si hay fecha fin y la nueva fecha inicio es después, mostrar error
          if (_endDate != null && picked.isAfter(_endDate!)) {
            _dateValidationError = 'La fecha de inicio no puede ser posterior a la fecha fin';
            return;
          }
          _startDate = picked;
          _dateValidationError = null; // Limpiar error si la fecha es válida
        } else {
          // Si hay fecha inicio y la nueva fecha fin es antes, mostrar error
          if (_startDate != null && picked.isBefore(_startDate!)) {
            _dateValidationError = 'La fecha fin no puede ser anterior a la fecha de inicio';
            return;
          }
          _endDate = picked;
          _dateValidationError = null; // Limpiar error si la fecha es válida
        }
      });
    }
  }

  Future<void> _generateReport(BuildContext context) async {
    // Validar fechas antes de generar reporte
    if (_startDate != null && _endDate != null && _startDate!.isAfter(_endDate!)) {
      setState(() {
        _dateValidationError = 'La fecha de inicio no puede ser posterior a la fecha fin';
      });
      return;
    }

    // Si hay error de validación, no generar reporte
    if (_dateValidationError != null) {
      return;
    }

    Navigator.of(context).pop();

    // Mostrar indicador de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Generando reporte PDF...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final reportService = RentalReportService();
      final rentalProvider = context.read<RentalProvider>();
      final success = await reportService.generatePDFReport(
        rentalProvider: rentalProvider,
        startDate: _startDate,
        endDate: _endDate,
        vehicleType: _selectedVehicleType,
        status: _selectedStatus,
        includeCharts: _includeCharts,
        includeSummary: _includeSummary,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Reporte PDF generado y descargado exitosamente!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el reporte. Intente nuevamente.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}