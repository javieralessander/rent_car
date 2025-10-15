import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../../brand/providers/brand_provider.dart';
import '../models/model_model.dart';
import '../models/model_form.dart';
import '../providers/model_provider.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  static const String name = 'models';

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModelProvider>().cargarModelos();
      context.read<BrandProvider>().cargarMarcas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelProvider>();
    final brandProvider = context.watch<BrandProvider>();
    final brandMap = {
      for (final brand in brandProvider.todasMarcas)
        brand.id: brand.descripcion,
    };
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Modelos de vehículos',
        isLoading: provider.isLoading,
        items: provider.modelos
            .map(
              (model) => _buildModelItem(
                context,
                model,
                model.marca?.descripcion ?? 'Sin marca',
              ),
            )
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
          onPressed: () => _showAddDialog(context, provider, brandProvider),
          icon: const Icon(Icons.add),
          label: const Text('Agregar modelo'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    ModelProvider provider,
    BrandProvider brandProvider,
  ) {
    if (brandProvider.todasMarcas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe registrar marcas antes de crear modelos.'),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => GenericFormDialog<ModelForm>(
        title: 'Agregar modelo',
        onSubmit: (modelForm) async {
          // Convertir ModelForm a Model completo
          final brand = brandProvider.todasMarcas.firstWhere(
            (b) => b.id == modelForm.marcaId,
            orElse: () => brandProvider.todasMarcas.first,
          );
          final model = modelForm.toModel(brand: brand);
          await provider.agregarModelo(model);
        },
        fromValues: (values, initial) => ModelForm(
          id: 0,
          descripcion: values['descripcion'] ?? '',
          marcaId: values['marcaId'] ?? brandProvider.todasMarcas.first.id!,
          estado: values['estado'] ?? true,
        ),
        fields: _modelFormFields(brandProvider),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Model model,
    ModelProvider provider,
    BrandProvider brandProvider,
  ) {
    if (brandProvider.todasMarcas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe registrar marcas antes de editar modelos.'),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => GenericFormDialog<ModelForm>(
        title: 'Editar modelo',
        initialData: ModelForm.fromModel(model),
        onSubmit: (modelForm) async {
          // Convertir ModelForm a Model completo
          final brand = brandProvider.todasMarcas.firstWhere(
            (b) => b.id == modelForm.marcaId,
            orElse: () => brandProvider.todasMarcas.first,
          );
          final updatedModel = modelForm.toModel(brand: brand);
          await provider.actualizarModelo(updatedModel);
        },
        fromValues: (values, initial) => ModelForm(
          id: initial?.id ?? model.id,
          descripcion: values['descripcion'] ?? initial?.descripcion ?? model.descripcion,
          marcaId: values['marcaId'] ?? initial?.marcaId ?? model.marca?.id ?? brandProvider.todasMarcas.first.id!,
          estado: values['estado'] ?? initial?.estado ?? model.estado,
        ),
        fields: _modelFormFields(brandProvider),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Model model,
    ModelProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar Modelo'),
            content: Text(
              '¿Está seguro que desea eliminar el modelo "${model.descripcion}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () async {
                  await provider.eliminarModelo(model.id!);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  List<FormFieldDefinition<ModelForm>> _modelFormFields(
    BrandProvider brandProvider,
  ) {
    return [
      FormFieldDefinition<ModelForm>(
        key: 'descripcion',
        label: 'Descripción',
        textValidator:
            (value) =>
                InputValidators.requiredText(value, fieldName: 'Descripción'),
        inputFormatters: InputFormatters.alphaNumeric(
          allowSpaces: true,
          maxLength: 50,
        ),
        textCapitalization: TextCapitalization.words,
        getValue: (v) => v?.descripcion ?? '',
        applyValue:
            (v, value) => ModelForm(
              id: v?.id ?? 0,
              descripcion: value,
              marcaId: v?.marcaId ?? brandProvider.todasMarcas.first.id!,
              estado: v?.estado ?? true,
            ),
      ),
      FormFieldDefinition<ModelForm>(
        key: 'marcaId',
        label: 'Marca',
        fieldType: 'dropdown',
        options:
            brandProvider.todasMarcas
                .map((brand) => {'value': brand.id, 'label': brand.descripcion})
                .toList(),
        validator: (value) {
          if (value == null) {
            return 'Marca es requerida';
          }
          return null;
        },
        getValue: (v) => v?.marcaId ?? brandProvider.todasMarcas.first.id,
        applyValue:
            (v, value) => ModelForm(
              id: v?.id ?? 0,
              descripcion: v?.descripcion ?? '',
              marcaId: value as int,
              estado: v?.estado ?? true,
            ),
      ),
      FormFieldDefinition<ModelForm>(
        key: 'estado',
        label: 'Estado',
        fieldType: 'dropdown',
        options: const [
          {'value': true, 'label': 'Activo'},
          {'value': false, 'label': 'Inactivo'},
        ],
        getValue: (v) => v?.estado ?? true,
        applyValue:
            (v, value) => ModelForm(
              id: v?.id ?? 0,
              descripcion: v?.descripcion ?? '',
              marcaId: v?.marcaId ?? brandProvider.todasMarcas.first.id!,
              estado: value as bool,
            ),
      ),
    ];
  }

  CollectionItemData _buildModelItem(
    BuildContext context,
    Model model,
    String brandName,
  ) {
    final modelProvider = context.read<ModelProvider>();
    final brandProvider = context.read<BrandProvider>();
    final isActive = model.estado;
    final initials =
        model.descripcion.isNotEmpty ? model.descripcion[0].toUpperCase() : 'M';

    return CollectionItemData(
      header: CollectionHeaderData(
        title: 'Modelo',
        subtitle: 'ID ${model.id}',
        backgroundColor: AppColors.secondary.withOpacity(0.08),
        leadingIcon: Icons.branding_watermark_outlined,
      ),
      badge: CollectionBadgeData(
        text: initials,
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      title: model.descripcion,
      subtitle: brandName,
      statusChip: CollectionStatusChip(
        label: isActive ? 'Activo' : 'Inactivo',
        backgroundColor:
            isActive ? AppColors.success.withOpacity(0.16) : AppColors.grayLight.withOpacity(0.45),
        textColor: isActive ? AppColors.success : AppColors.grayDark,
      ),
      details: [
        CollectionDetailInfo(
          label: 'Marca',
          value: brandName,
          inlineValue: brandName,
          icon: Icons.branding_watermark_outlined,
          iconColor: AppColors.secondary,
          iconBackground: AppColors.secondary.withOpacity(0.18),
        ),
        CollectionDetailInfo(
          label: 'Identificador',
          value: '#${model.id}',
          inlineValue: 'ID ${model.id}',
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
          onPressed: () => _showEditDialog(
            context,
            model,
            modelProvider,
            brandProvider,
          ),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => _showDeleteDialog(
            context,
            model,
            modelProvider,
          ),
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
