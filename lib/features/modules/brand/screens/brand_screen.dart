import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../models/brand_model.dart';
import '../providers/brand_provider.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  static const String name = 'brands';

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().cargarMarcas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrandProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Lista de marcas',
        isLoading: provider.isLoading,
        items: provider.marcas
            .map((brand) => _buildBrandItem(context, brand))
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
          onPressed: () => _openBrandDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar marca'),
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

  Future<void> _openBrandDialog(BuildContext context, {Brand? initial}) async {
    await showDialog(
      context: context,
      builder:
          (_) => GenericFormDialog<Brand>(
            title: initial == null ? 'Agregar Marca' : 'Editar Marca',
            initialData: initial,
            onSubmit: (data) async {
              if (initial == null) {
                await context.read<BrandProvider>().agregarMarca(data);
              } else {
                await context.read<BrandProvider>().actualizarMarca(data);
              }
            },
            fromValues:
                (values, previous) => Brand(
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
              FormFieldDefinition<Brand>(
                key: 'descripcion',
                label: 'Descripción',
                textValidator:
                    (value) => InputValidators.requiredText(
                      value,
                      fieldName: 'Descripción',
                    ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
                  LengthLimitingTextInputFormatter(40),
                ],
                textCapitalization: TextCapitalization.words,
                getValue: (b) => b?.descripcion ?? '',
                applyValue:
                    (b, value) => Brand(
                      id: b?.id ?? initial?.id ?? 0,
                      descripcion: value,
                      estado: b?.estado ?? initial?.estado ?? true,
                    ),
              ),
              FormFieldDefinition<Brand>(
                key: 'estado',
                label: 'Estado',
                fieldType: 'dropdown',
                options: const [
                  {'value': true, 'label': 'Activo'},
                  {'value': false, 'label': 'Inactivo'},
                ],
                getValue: (b) => b?.estado,
                applyValue:
                    (b, value) => Brand(
                      id: b?.id ?? initial?.id ?? 0,
                      descripcion: b?.descripcion ?? initial?.descripcion ?? '',
                      estado: value as bool,
                    ),
              ),
            ],
          ),
    );
  }

  CollectionItemData _buildBrandItem(
    BuildContext context,
    Brand brand,
  ) {
    final isActive = brand.estado;
    final initials =
        brand.descripcion.isNotEmpty ? brand.descripcion[0].toUpperCase() : 'M';

    return CollectionItemData(
      header: CollectionHeaderData(
        title: 'Marca registrada',
        subtitle: 'ID ${brand.id}',
        backgroundColor: AppColors.primary.withOpacity(0.05),
        leadingIcon: Icons.local_offer_outlined,
      ),
      badge: CollectionBadgeData(text: initials),
      title: brand.descripcion,
      subtitle: 'Disponible para asignar vehículos.',
      statusChip: CollectionStatusChip(
        label: isActive ? 'Activa' : 'Inactiva',
        backgroundColor:
            isActive ? AppColors.success.withOpacity(0.16) : AppColors.grayLight.withOpacity(0.45),
        textColor: isActive ? AppColors.success : AppColors.grayDark,
      ),
      details: [
        CollectionDetailInfo(
          label: 'Identificador',
          value: '#${brand.id}',
          inlineValue: 'ID ${brand.id}',
          icon: Icons.confirmation_number_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Estado',
          value: isActive ? 'Activa' : 'Inactiva',
          inlineValue: isActive ? 'Activa' : 'Inactiva',
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
          onPressed: () => _openBrandDialog(context, initial: brand),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => ConfirmationDialog.showDeleteDialog(
            context: context,
            title: 'Eliminar Marca',
            itemName: brand.descripcion,
            additionalInfo: 'Se eliminará permanentemente del sistema.',
            onConfirm: () => context.read<BrandProvider>().eliminarMarca(brand.id),
          ),
        ),
      ],
      footerStatus: CollectionFooterStatus(
        label: isActive ? 'Activa' : 'Inactiva',
        color: isActive ? AppColors.success : AppColors.grayDark,
        icon: isActive ? Icons.check_circle : Icons.pause_circle_filled,
      ),
    );
  }
}
