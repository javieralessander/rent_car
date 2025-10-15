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
import '../models/rental_model.dart';
import '../models/rental_form.dart';
import '../providers/rental_provider.dart';

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
        topRightWidget: FloatingActionButton.extended(
          onPressed: () => _openRentalDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva renta'),
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

  Future<void> _openRentalDialog(
    BuildContext context, {
    Rental? initial,
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
      builder: (_) => GenericFormDialog<RentalForm>(
        title: initial == null ? 'Nueva Renta' : 'Editar Renta',
        initialData: initial != null ? RentalForm.fromRental(initial) : null,
        onSubmit: (rentalForm) async {
          // Convertir RentalForm a Rental completo
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

          if (initial == null) {
            await context.read<RentalProvider>().agregarRenta(rental);
          } else {
            await context.read<RentalProvider>().actualizarRenta(rental);
          }
        },
        fromValues: (values, previous) => RentalForm(
          noRenta: previous?.noRenta ?? (initial != null ? RentalForm.fromRental(initial).noRenta : null),
          empleadoId: values['empleadoId'] ?? previous?.empleadoId ?? (initial != null ? RentalForm.fromRental(initial).empleadoId : employeeProvider.todosEmpleados.first.id!),
          vehiculoId: values['vehiculoId'] ?? previous?.vehiculoId ?? (initial != null ? RentalForm.fromRental(initial).vehiculoId : vehicleProvider.todosVehiculos.first.id!),
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
          estado: values['estado'] ?? previous?.estado ?? (initial != null ? RentalForm.fromRental(initial).estado : EstadoRenta.ACTIVA),
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
            getValue: (v) => v?.empleadoId ?? employeeProvider.todosEmpleados.first.id,
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
            options: vehicleProvider.todosVehiculos
                .map((vehicle) => {'value': vehicle.id, 'label': '${vehicle.noPlaca} - ${vehicle.descripcion}'})
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Vehículo es requerido';
              }
              return null;
            },
            getValue: (v) => v?.vehiculoId ?? vehicleProvider.todosVehiculos.first.id,
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
            getValue: (v) => v?.clienteId ?? clientProvider.todosClientes.first.id,
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
            getValue: (v) => v?.fechaRenta ?? DateTime.now(),
            validator: (value) {
              if (value == null) return 'La fecha de renta es requerida';
              if (value is DateTime && value.isAfter(DateTime.now())) {
                return 'La fecha de renta no puede ser futura';
              }
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
            fieldType: 'date',
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
            ),
            getValue: (v) => v?.montoDia ?? 0.0,
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
            ),
            getValue: (v) => v?.cantidadDias ?? 1,
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
            getValue: (v) => v?.comentario ?? '',
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
              {'value': true, 'label': 'Activo'},
              {'value': false, 'label': 'Inactivo'},
            ],
            getValue: (v) => v?.estado == EstadoRenta.ACTIVA,
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
              estado: (value as bool) ? EstadoRenta.ACTIVA : EstadoRenta.DEVUELTA,
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
        label: isDevuelto ? 'Devuelto' : 'En curso',
        backgroundColor: isDevuelto ? AppColors.info.withOpacity(0.16) : AppColors.warning.withOpacity(0.16),
        textColor: isDevuelto ? AppColors.info : AppColors.warning,
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
          inlineValue: 'Cliente: $clientName',
          icon: Icons.person_outlined,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primary.withOpacity(0.15),
        ),
        CollectionDetailInfo(
          label: 'Vehículo',
          value: vehicleName,
          inlineValue: 'Vehículo: $vehicleName',
          icon: Icons.directions_car_outlined,
          iconColor: AppColors.secondary,
          iconBackground: AppColors.secondary.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Empleado',
          value: employeeName,
          inlineValue: 'Empleado: $employeeName',
          icon: Icons.badge_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.14),
        ),
        CollectionDetailInfo(
          label: 'Fecha Renta',
          value: '${renta.fechaRenta.day}/${renta.fechaRenta.month}/${renta.fechaRenta.year}',
          inlineValue: 'Inicio: ${renta.fechaRenta.day}/${renta.fechaRenta.month}/${renta.fechaRenta.year}',
          icon: Icons.calendar_today_outlined,
          iconColor: AppColors.success,
          iconBackground: AppColors.success.withOpacity(0.16),
        ),
        if (renta.fechaDevolucion != null)
          CollectionDetailInfo(
            label: 'Fecha devolución',
            value: '${renta.fechaDevolucion!.day}/${renta.fechaDevolucion!.month}/${renta.fechaDevolucion!.year}',
            inlineValue: 'Fin: ${renta.fechaDevolucion!.day}/${renta.fechaDevolucion!.month}/${renta.fechaDevolucion!.year}',
            icon: Icons.event_available_outlined,
            iconColor: AppColors.success,
            iconBackground: AppColors.success.withOpacity(0.16),
          ),
        CollectionDetailInfo(
          label: 'Monto por día',
          value: InputFormatters.formatCurrency(renta.montoDia),
          inlineValue: '${InputFormatters.formatCurrency(renta.montoDia)}/día',
          icon: Icons.attach_money_outlined,
          iconColor: AppColors.warning,
          iconBackground: AppColors.warning.withOpacity(0.18),
        ),
        CollectionDetailInfo(
          label: 'Días',
          value: '${renta.cantidadDias} días',
          inlineValue: '${renta.cantidadDias} días',
          icon: Icons.schedule_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.14),
        ),
        CollectionDetailInfo(
          label: 'Total',
          value: InputFormatters.formatCurrency(montoTotal),
          inlineValue: 'Total: ${InputFormatters.formatCurrency(montoTotal)}',
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
        if (!isDevuelto)
          CollectionActionData(
            label: 'Devolver',
            icon: Icons.assignment_return_outlined,
            variant: CollectionActionVariant.secondary,
            onPressed: () => _devolverRenta(context, renta),
          ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => context.read<RentalProvider>().eliminarRenta(renta.noRenta!),
        ),
      ],
      footerStatus: CollectionFooterStatus(
        label: isDevuelto ? 'Devuelto' : 'En curso',
        color: isDevuelto ? AppColors.info : AppColors.warning,
        icon: isDevuelto ? Icons.assignment_return : Icons.access_time,
      ),
    );
  }

  Future<void> _devolverRenta(BuildContext context, Rental renta) async {
    final rentaDevuelta = Rental(
      noRenta: renta.noRenta,
      empleado: renta.empleado,
      vehiculo: renta.vehiculo,
      cliente: renta.cliente,
      fechaRenta: renta.fechaRenta,
      fechaDevolucion: DateTime.now(),
      montoDia: renta.montoDia,
      cantidadDias: renta.cantidadDias,
      comentario: renta.comentario,
      estado: renta.estado,
    );

    await context.read<RentalProvider>().actualizarRenta(rentaDevuelta);
  }
}