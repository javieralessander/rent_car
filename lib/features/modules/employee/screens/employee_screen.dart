import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../models/employee_model.dart';
import '../providers/employee_provider.dart';

class EmployeeScreen extends StatefulWidget {
  static const String name = 'employees';
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().cargarEmpleados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Lista de empleados',
        isLoading: provider.isLoading,
        items: provider.empleados
            .map((empleado) => _buildEmployeeItem(context, empleado))
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
          onPressed: () => _openEmployeeDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar empleado'),
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

  Future<void> _openEmployeeDialog(
    BuildContext context, {
    Employee? initial,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => GenericFormDialog<Employee>(
        title: initial == null ? 'Agregar Empleado' : 'Editar Empleado',
        initialData: initial,
        onSubmit: (data) async {
          if (initial == null) {
            await context.read<EmployeeProvider>().agregarEmpleado(data);
          } else {
            await context.read<EmployeeProvider>().actualizarEmpleado(data);
          }
        },
        fromValues: (values, previous) => Employee(
          id: previous?.id ?? initial?.id ?? 0,
          nombre: values['nombre'] ?? previous?.nombre ?? initial?.nombre ?? '',
          cedula: values['cedula'] ?? previous?.cedula ?? initial?.cedula ?? '',
          tandaLabor: values['tandaLabor'] ?? previous?.tandaLabor ?? initial?.tandaLabor ?? TandaLabor.MATUTINA,
          porcientoComision: (() {
            final val = values['porcientoComision'];
            if (val is double) return val;
            if (val is int) return val.toDouble();
            if (val is String) return double.tryParse(val) ?? 0.0;
            return previous?.porcientoComision ?? initial?.porcientoComision ?? 0.0;
          })(),
          fechaIngreso: values['fechaIngreso'] ?? previous?.fechaIngreso ?? initial?.fechaIngreso ?? DateTime.now(),
          estado: values['estado'] ?? previous?.estado ?? initial?.estado ?? true,
        ),
        fields: [
          FormFieldDefinition<Employee>(
            key: 'nombre',
            label: 'Nombre',
            textValidator: (value) => InputValidators.requiredText(
              value,
              fieldName: 'Nombre',
            ),
            inputFormatters: InputFormatters.names(maxLength: 60),
            textCapitalization: TextCapitalization.words,
            getValue: (v) => v?.nombre ?? '',
            applyValue: (v, value) => Employee(
              id: v?.id ?? initial?.id ?? 0,
              nombre: value,
              cedula: v?.cedula ?? initial?.cedula ?? '',
              tandaLabor: v?.tandaLabor ?? initial?.tandaLabor ?? TandaLabor.MATUTINA,
              porcientoComision: v?.porcientoComision ?? initial?.porcientoComision ?? 0.0,
              fechaIngreso: v?.fechaIngreso ?? initial?.fechaIngreso ?? DateTime.now(),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Employee>(
            key: 'cedula',
            label: 'Cédula',
            textValidator: (value) => InputValidators.cedulaDominicana(
              value,
              fieldName: 'Cédula',
            ),
            inputFormatters: InputFormatters.cedula(),
            getValue: (v) => v?.cedula ?? '',
            applyValue: (v, value) => Employee(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: value,
              tandaLabor: v?.tandaLabor ?? initial?.tandaLabor ?? TandaLabor.MATUTINA,
              porcientoComision: v?.porcientoComision ?? initial?.porcientoComision ?? 0.0,
              fechaIngreso: v?.fechaIngreso ?? initial?.fechaIngreso ?? DateTime.now(),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Employee>(
            key: 'tandaLabor',
            label: 'Tanda de Labor',
            fieldType: 'dropdown',
            options: const [
              {'value': TandaLabor.MATUTINA, 'label': 'Matutina'},
              {'value': TandaLabor.VESPERTINA, 'label': 'Vespertina'},
              {'value': TandaLabor.NOCTURNA, 'label': 'Nocturna'},
            ],
            validator: (value) {
              if (value == null) {
                return 'Tanda de labor es requerida';
              }
              return null;
            },
            getValue: (v) => v?.tandaLabor,
            applyValue: (v, value) => Employee(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              tandaLabor: value as TandaLabor,
              porcientoComision: v?.porcientoComision ?? initial?.porcientoComision ?? 0.0,
              fechaIngreso: v?.fechaIngreso ?? initial?.fechaIngreso ?? DateTime.now(),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Employee>(
            key: 'porcientoComision',
            label: 'Porciento de Comisión (%)',
            fieldType: 'decimal',
            textValidator: (value) => InputValidators.requiredDecimal(
              value,
              fieldName: 'Porciento de Comisión',
              minValue: 0.0,
              maxValue: 100.0,
            ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]{0,2}')),
                // Solo permite números positivos y hasta dos decimales
              ],
            getValue: (v) => v?.porcientoComision,
            applyValue: (v, value) => Employee(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              tandaLabor: v?.tandaLabor ?? initial?.tandaLabor ?? TandaLabor.MATUTINA,
              porcientoComision: (() {
                if (value is double) return value;
                if (value is int) return value.toDouble();
                if (value is String) return double.tryParse(value) ?? 0.0;
                return v?.porcientoComision ?? initial?.porcientoComision ?? 0.0;
              })(),
              fechaIngreso: v?.fechaIngreso ?? initial?.fechaIngreso ?? DateTime.now(),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Employee>(
            key: 'fechaIngreso',
            label: 'Fecha de Ingreso',
            fieldType: 'date',
            getValue: (v) => v?.fechaIngreso,
            applyValue: (v, value) => Employee(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              tandaLabor: v?.tandaLabor ?? initial?.tandaLabor ?? TandaLabor.MATUTINA,
              porcientoComision: v?.porcientoComision ?? initial?.porcientoComision ?? 0.0,
              fechaIngreso: value as DateTime,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          FormFieldDefinition<Employee>(
            key: 'estado',
            label: 'Estado',
            fieldType: 'dropdown',
            options: const [
              {'value': true, 'label': 'Activo'},
              {'value': false, 'label': 'Inactivo'},
            ],
            getValue: (v) => v?.estado,
            applyValue: (v, value) => Employee(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              tandaLabor: v?.tandaLabor ?? initial?.tandaLabor ?? TandaLabor.MATUTINA,
              porcientoComision: v?.porcientoComision ?? initial?.porcientoComision ?? 0.0,
              fechaIngreso: v?.fechaIngreso ?? initial?.fechaIngreso ?? DateTime.now(),
              estado: value as bool,
            ),
          ),
        ],
      ),
    );
  }

  CollectionItemData _buildEmployeeItem(
    BuildContext context,
    Employee empleado,
  ) {
    final isActive = empleado.estado;
    final initials = empleado.nombre.isNotEmpty ? empleado.nombre[0].toUpperCase() : 'E';
    final tandaText = _getTandaLaborText(empleado.tandaLabor);

    return CollectionItemData(
      header: CollectionHeaderData(
        title: isActive ? 'Empleado activo' : 'Empleado inactivo',
        subtitle: 'ID ${empleado.id}',
        backgroundColor: AppColors.primary.withOpacity(0.05),
        leadingIcon: Icons.badge_outlined,
      ),
      badge: CollectionBadgeData(text: initials),
      title: empleado.nombre,
      subtitle: '$tandaText • Cédula: ${empleado.cedula}',
      statusChip: CollectionStatusChip(
        label: isActive ? 'Activo' : 'Inactivo',
        backgroundColor: isActive ? AppColors.success.withOpacity(0.16) : AppColors.grayLight.withOpacity(0.45),
        textColor: isActive ? AppColors.success : AppColors.grayDark,
      ),
      details: [
        CollectionDetailInfo(
          label: 'Cédula',
          value: empleado.cedula,
          inlineValue: empleado.cedula,
          icon: Icons.credit_card_outlined,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primary.withOpacity(0.14),
        ),
        CollectionDetailInfo(
          label: 'Tanda',
          value: tandaText,
          inlineValue: tandaText,
          icon: Icons.schedule_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Comisión',
          value: '${empleado.porcientoComision.toStringAsFixed(1)}%',
          inlineValue: '${empleado.porcientoComision.toStringAsFixed(1)}%',
          icon: Icons.percent_outlined,
          iconColor: AppColors.warning,
          iconBackground: AppColors.warning.withOpacity(0.18),
        ),
        CollectionDetailInfo(
          label: 'Ingreso',
          value: '${empleado.fechaIngreso.day}/${empleado.fechaIngreso.month}/${empleado.fechaIngreso.year}',
          inlineValue: '${empleado.fechaIngreso.day}/${empleado.fechaIngreso.month}/${empleado.fechaIngreso.year}',
          icon: Icons.calendar_today_outlined,
          iconColor: AppColors.success,
          iconBackground: AppColors.success.withOpacity(0.16),
        ),
      ],
      actions: [
        CollectionActionData(
          label: 'Editar',
          icon: Icons.edit_outlined,
          variant: CollectionActionVariant.primary,
          onPressed: () => _openEmployeeDialog(context, initial: empleado),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => context.read<EmployeeProvider>().eliminarEmpleado(empleado.id),
        ),
      ],
      footerStatus: CollectionFooterStatus(
        label: isActive ? 'Activo' : 'Inactivo',
        color: isActive ? AppColors.success : AppColors.grayDark,
        icon: isActive ? Icons.check_circle : Icons.pause_circle_filled,
      ),
    );
  }

  String _getTandaLaborText(TandaLabor tanda) {
    switch (tanda) {
      case TandaLabor.MATUTINA:
        return 'Matutina';
      case TandaLabor.VESPERTINA:
        return 'Vespertina';
      case TandaLabor.NOCTURNA:
        return 'Nocturna';
    }
  }
}