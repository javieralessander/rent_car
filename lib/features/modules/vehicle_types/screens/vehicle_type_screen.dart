import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../models/vehicle_type_model.dart';
import '../providers/vehicle_type_provider.dart';

class VehicleTypeScreen extends StatefulWidget {
  const VehicleTypeScreen({super.key});

  static const String name = 'vehicle_types';

  @override
  State<VehicleTypeScreen> createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleTypeProvider>().cargarTiposVehiculos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleTypeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Tipos de vehículos',
        isLoading: provider.isLoading,
        items: provider.tiposVehiculos
            .map((tipo) => _buildVehicleTypeItem(context, tipo))
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
          onPressed: () => _openVehicleTypeDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar tipo'),
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

  Future<void> _openVehicleTypeDialog(
    BuildContext context, {
    VehicleType? initial,
  }) async {
    await showDialog(
      context: context,
      builder:
          (_) => GenericFormDialog<VehicleType>(
            title:
                initial == null
                    ? 'Agregar Tipo de Vehículo'
                    : 'Editar Tipo de Vehículo',
            initialData: initial,
            onSubmit: (data) async {
              if (initial == null) {
                await context.read<VehicleTypeProvider>().agregarTipoVehiculo(
                  data,
                );
              } else {
                await context
                    .read<VehicleTypeProvider>()
                    .actualizarTipoVehiculo(data);
              }
            },
            fromValues:
                (values, previous) => VehicleType(
                  id: previous?.id ?? initial?.id ?? 0,
                  descripcion:
                      values['descripcion'] ??
                      previous?.descripcion ??
                      initial?.descripcion ??
                      '',
                  estado:
                      values['estado'] ??
                      previous?.estado ??
                      initial?.estado ??
                      true,
                ),
            fields: [
              FormFieldDefinition<VehicleType>(
                key: 'descripcion',
                label: 'Descripción',
                textValidator:
                    (value) => InputValidators.requiredText(
                      value,
                      fieldName: 'Descripción',
                    ),
                inputFormatters: InputFormatters.alphaNumeric(
                  maxLength: 40,
                  allowSpaces: true,
                ),
                textCapitalization: TextCapitalization.words,
                getValue: (v) => v?.descripcion ?? '',
                applyValue:
                    (v, value) => VehicleType(
                      id: v?.id ?? initial?.id ?? 0,
                      descripcion: value,
                      estado: v?.estado ?? initial?.estado ?? true,
                    ),
              ),
              FormFieldDefinition<VehicleType>(
                key: 'estado',
                label: 'Estado',
                fieldType: 'dropdown',
                options: const [
                  {'value': true, 'label': 'Activo'},
                  {'value': false, 'label': 'Inactivo'},
                ],
                getValue: (v) => v?.estado ?? true,
                applyValue:
                    (v, value) => VehicleType(
                      id: v?.id ?? initial?.id ?? 0,
                      descripcion: v?.descripcion ?? initial?.descripcion ?? '',
                      estado: value as bool,
                    ),
              ),
            ],
          ),
    );
  }

  CollectionItemData _buildVehicleTypeItem(
    BuildContext context,
    VehicleType tipo,
  ) {
    final isActive = tipo.estado;
    final initials =
        tipo.descripcion.isNotEmpty ? tipo.descripcion[0].toUpperCase() : 'V';

    return CollectionItemData(
      header: CollectionHeaderData(
        title: 'Tipo de vehículo',
        subtitle: 'ID ${tipo.id}',
        backgroundColor: AppColors.primary.withOpacity(0.05),
        leadingIcon: Icons.directions_car_filled_outlined,
      ),
      badge: CollectionBadgeData(text: initials),
      title: tipo.descripcion,
      subtitle: 'Clasificación del catálogo de vehículos.',
      statusChip: CollectionStatusChip(
        label: isActive ? 'Activo' : 'Inactivo',
        backgroundColor:
            isActive ? AppColors.success.withOpacity(0.16) : AppColors.grayLight.withOpacity(0.45),
        textColor: isActive ? AppColors.success : AppColors.grayDark,
      ),
      details: [
        CollectionDetailInfo(
          label: 'Identificador',
          value: '#${tipo.id}',
          inlineValue: 'ID ${tipo.id}',
          icon: Icons.confirmation_number_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Estado',
          value: isActive ? 'Activo' : 'Inactivo',
          inlineValue: isActive ? 'Activo' : 'Inactivo',
          icon:
              isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
          iconColor: isActive ? AppColors.success : AppColors.grayDark,
          iconBackground:
              (isActive ? AppColors.success : AppColors.grayDark).withOpacity(0.12),
        ),
      ],
      actions: [
        CollectionActionData(
          label: 'Editar',
          icon: Icons.edit_outlined,
          variant: CollectionActionVariant.primary,
          onPressed: () => _openVehicleTypeDialog(context, initial: tipo),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => context
              .read<VehicleTypeProvider>()
              .eliminarTipoVehiculo(tipo.id),
        ),
      ],
      footerStatus: CollectionFooterStatus(
        label: isActive ? 'Activo' : 'Inactivo',
        color: isActive ? AppColors.success : AppColors.grayDark,
        icon: isActive ? Icons.check_circle : Icons.pause_circle_filled,
      ),
    );
  }
}
