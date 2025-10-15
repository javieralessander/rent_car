import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../../brand/providers/brand_provider.dart';
import '../../fuel_types/providers/fuel_type_provider.dart';
import '../../models/providers/model_provider.dart';
import '../../vehicle_types/providers/vehicle_type_provider.dart';
import '../models/vehicle_model.dart';
import '../models/vehicle_form_model.dart';
import '../providers/vehicle_provider.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  static const String name = 'vehicles';

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().cargarVehiculos();
      context.read<VehicleTypeProvider>().cargarTiposVehiculos();
      context.read<BrandProvider>().cargarMarcas();
      context.read<ModelProvider>().cargarModelos();
      context.read<FuelTypeProvider>().cargarTiposCombustible();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final typeProvider = context.watch<VehicleTypeProvider>();
    final brandProvider = context.watch<BrandProvider>();
    final modelProvider = context.watch<ModelProvider>();
    final fuelProvider = context.watch<FuelTypeProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    final typeMap = {
      for (final type in typeProvider.todosTiposVehiculos)
        type.id: type.descripcion,
    };
    final brandMap = {
      for (final brand in brandProvider.todasMarcas)
        brand.id: brand.descripcion,
    };
    final modelMap = {
      for (final model in modelProvider.todosModelos)
        model.id: model.descripcion,
    };
    final fuelMap = {
      for (final fuel in fuelProvider.todosTiposCombustible)
        fuel.id: fuel.descripcion,
    };

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Vehículos',
        isLoading: vehicleProvider.isLoading,
        items: vehicleProvider.vehiculos
            .map(
              (vehicle) => _buildVehicleItem(
                context,
                vehicle,
                vehicle.tipoVehiculo?.descripcion ?? 'Sin tipo',
                vehicle.marca?.descripcion ?? 'Sin marca',
                vehicle.modelo?.descripcion ?? 'Sin modelo',
                vehicle.tipoCombustible?.descripcion ?? 'Sin combustible',
              ),
            )
            .toList(),
        viewMode: _viewMode,
        onViewModeChanged: (mode) => setState(() => _viewMode = mode),
        currentPage: vehicleProvider.paginaActual,
        totalPages: vehicleProvider.totalPaginas,
        totalItems: vehicleProvider.totalRegistros,
        itemsPerPage: vehicleProvider.registrosPorPagina,
        onPageChanged: vehicleProvider.cambiarPagina,
        onItemsPerPageChanged: vehicleProvider.cambiarRegistrosPorPagina,
        onSearch: (value) => vehicleProvider.busqueda = value,
        topRightWidget: FloatingActionButton.extended(
          onPressed:
              () => _openVehicleDialog(
                context,
                vehicleProvider,
                typeProvider,
                brandProvider,
                modelProvider,
                fuelProvider,
              ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar vehículo'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }

  void _openVehicleDialog(
    BuildContext context,
    VehicleProvider vehicleProvider,
    VehicleTypeProvider typeProvider,
    BrandProvider brandProvider,
    ModelProvider modelProvider,
    FuelTypeProvider fuelProvider, {
    Vehicle? initial,
  }) {
    if (typeProvider.todosTiposVehiculos.isEmpty ||
        brandProvider.todasMarcas.isEmpty ||
        modelProvider.todosModelos.isEmpty ||
        fuelProvider.todosTiposCombustible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verifique que existan tipos, marcas, modelos y combustibles antes de continuar.',
          ),
        ),
      );
      return;
    }

    final typeOptions = typeProvider.todosTiposVehiculos
        .map((e) => {'value': e.id, 'label': e.descripcion})
        .toList();
    final brandOptions = brandProvider.todasMarcas
        .map((e) => {'value': e.id, 'label': e.descripcion})
        .toList();
    final modelOptions = modelProvider.todosModelos
        .map((e) => {'value': e.id, 'label': e.descripcion})
        .toList();
    final fuelOptions = fuelProvider.todosTiposCombustible
        .map((e) => {'value': e.id, 'label': e.descripcion})
        .toList();

    showDialog(
      context: context,
      builder: (_) => GenericFormDialog<VehicleForm>(
        title: initial == null ? 'Agregar vehículo' : 'Editar vehículo',
        initialData: initial != null ? VehicleForm.fromVehicle(initial) : null,
        onSubmit: (vehicleForm) async {
          // Convertir VehicleForm a Vehicle completo
          final vehicleType = typeProvider.todosTiposVehiculos.firstWhere(
            (t) => t.id == vehicleForm.tipoVehiculoId,
            orElse: () => typeProvider.todosTiposVehiculos.first,
          );
          final brand = brandProvider.todasMarcas.firstWhere(
            (b) => b.id == vehicleForm.marcaId,
            orElse: () => brandProvider.todasMarcas.first,
          );
          final model = modelProvider.todosModelos.firstWhere(
            (m) => m.id == vehicleForm.modeloId,
            orElse: () => modelProvider.todosModelos.first,
          );
          final fuelType = fuelProvider.todosTiposCombustible.firstWhere(
            (f) => f.id == vehicleForm.tipoCombustibleId,
            orElse: () => fuelProvider.todosTiposCombustible.first,
          );

          final vehicle = vehicleForm.toVehicle(
            vehicleType: vehicleType,
            brand: brand,
            model: model,
            fuelType: fuelType,
          );

          if (initial == null) {
            await vehicleProvider.agregarVehiculo(vehicle);
          } else {
            await vehicleProvider.actualizarVehiculo(vehicle);
          }
        },
        fromValues: (values, previous) => VehicleForm(
          id: previous?.id ?? (initial != null ? VehicleForm.fromVehicle(initial).id : null),
          descripcion: values['descripcion'] ?? previous?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
          noChasis: values['noChasis'] ?? previous?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
          noMotor: values['noMotor'] ?? previous?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
          noPlaca: values['noPlaca'] ?? previous?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
          tipoVehiculoId: values['tipoVehiculoId'] ?? previous?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : typeOptions.first['value'] as int),
          marcaId: values['marcaId'] ?? previous?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : brandOptions.first['value'] as int),
          modeloId: values['modeloId'] ?? previous?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : modelOptions.first['value'] as int),
          tipoCombustibleId: values['tipoCombustibleId'] ?? previous?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : fuelOptions.first['value'] as int),
          estado: values['estado'] ?? previous?.estado ?? (initial != null ? VehicleForm.fromVehicle(initial).estado : true),
        ),
        fields: _vehicleFormFields(
          typeOptions: typeOptions,
          brandOptions: brandOptions,
          modelOptions: modelOptions,
          fuelOptions: fuelOptions,
          initial: initial,
        ),
      ),
    );
  }

  List<FormFieldDefinition<VehicleForm>> _vehicleFormFields({
    required List<Map<String, Object?>> typeOptions,
    required List<Map<String, Object?>> brandOptions,
    required List<Map<String, Object?>> modelOptions,
    required List<Map<String, Object?>> fuelOptions,
    Vehicle? initial,
  }) {
    int defaultOption(List<Map<String, Object?>> options) =>
        options.first['value'] as int;

    return [
      FormFieldDefinition<VehicleForm>(
        key: 'descripcion',
        label: 'Descripción',
        textValidator:
            (value) =>
                InputValidators.requiredText(value, fieldName: 'Descripción'),
        inputFormatters: InputFormatters.alphaNumeric(
          maxLength: 60,
          allowSpaces: true,
        ),
        textCapitalization: TextCapitalization.sentences,
        getValue: (v) => v?.descripcion ?? '',
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: value,
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? (initial != null ? VehicleForm.fromVehicle(initial).estado : true),
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'noPlaca',
        label: 'Número de placa',
        textValidator:
            (value) => InputValidators.alphaNumeric(
              value,
              fieldName: 'Número de placa',
              minLength: 5,
              maxLength: 10,
            ),
        inputFormatters: InputFormatters.plate(maxLength: 10),
        textCapitalization: TextCapitalization.characters,
        getValue: (v) => v?.noPlaca ?? '',
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: value,
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? (initial != null ? VehicleForm.fromVehicle(initial).estado : true),
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'noChasis',
        label: 'Número de chasis',
        textValidator:
            (value) => InputValidators.alphaNumeric(
              value,
              fieldName: 'Número de chasis',
              minLength: 6,
              maxLength: 25,
            ),
        inputFormatters: InputFormatters.alphaNumeric(maxLength: 25),
        textCapitalization: TextCapitalization.characters,
        getValue: (v) => v?.noChasis ?? '',
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: value,
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'noMotor',
        label: 'Número de motor',
        textValidator:
            (value) => InputValidators.alphaNumeric(
              value,
              fieldName: 'Número de motor',
              minLength: 4,
              maxLength: 25,
            ),
        inputFormatters: InputFormatters.alphaNumeric(maxLength: 25),
        textCapitalization: TextCapitalization.characters,
        getValue: (v) => v?.noMotor ?? '',
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: value,
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'tipoVehiculoId',
        label: 'Tipo de vehículo',
        fieldType: 'dropdown',
        options: typeOptions,
        validator: (value) {
          if (value == null) {
            return 'Tipo de vehículo es requerido';
          }
          return null;
        },
        getValue: (v) => v?.tipoVehiculoId,
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: value as int,
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'marcaId',
        label: 'Marca',
        fieldType: 'dropdown',
        options: brandOptions,
        validator: (value) {
          if (value == null) {
            return 'Marca es requerida';
          }
          return null;
        },
        getValue: (v) => v?.marcaId,
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: value as int,
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'modeloId',
        label: 'Modelo',
        fieldType: 'dropdown',
        options: modelOptions,
        validator: (value) {
          if (value == null) {
            return 'Modelo es requerido';
          }
          return null;
        },
        getValue: (v) => v?.modeloId,
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: value as int,
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'tipoCombustibleId',
        label: 'Tipo de combustible',
        fieldType: 'dropdown',
        options: fuelOptions,
        validator: (value) {
          if (value == null) {
            return 'Tipo de combustible es requerido';
          }
          return null;
        },
        getValue: (v) => v?.tipoCombustibleId,
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: value as int,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<VehicleForm>(
        key: 'estado',
        label: 'Estado',
        fieldType: 'dropdown',
        options: const [
          {'value': true, 'label': 'Activo'},
          {'value': false, 'label': 'Inactivo'},
        ],
        getValue: (v) => v?.estado,
        applyValue:
            (v, value) => VehicleForm(
              id: v?.id ?? initial?.id,
              descripcion: v?.descripcion ?? (initial != null ? VehicleForm.fromVehicle(initial).descripcion : ''),
              noChasis: v?.noChasis ?? (initial != null ? VehicleForm.fromVehicle(initial).noChasis : ''),
              noMotor: v?.noMotor ?? (initial != null ? VehicleForm.fromVehicle(initial).noMotor : ''),
              noPlaca: v?.noPlaca ?? (initial != null ? VehicleForm.fromVehicle(initial).noPlaca : ''),
              tipoVehiculoId: v?.tipoVehiculoId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoVehiculoId : defaultOption(typeOptions)),
              marcaId: v?.marcaId ?? (initial != null ? VehicleForm.fromVehicle(initial).marcaId : defaultOption(brandOptions)),
              modeloId: v?.modeloId ?? (initial != null ? VehicleForm.fromVehicle(initial).modeloId : defaultOption(modelOptions)),
              tipoCombustibleId: v?.tipoCombustibleId ?? (initial != null ? VehicleForm.fromVehicle(initial).tipoCombustibleId : defaultOption(fuelOptions)),
              estado: value as bool,
            ),
      ),
    ];
  }

  CollectionItemData _buildVehicleItem(
    BuildContext context,
    Vehicle vehicle,
    String typeName,
    String brandName,
    String modelName,
    String fuelName,
  ) {
    final vehicleProvider = context.read<VehicleProvider>();
    final typeProvider = context.read<VehicleTypeProvider>();
    final brandProvider = context.read<BrandProvider>();
    final modelProvider = context.read<ModelProvider>();
    final fuelProvider = context.read<FuelTypeProvider>();
    final isActive = vehicle.estado;
    final badgeLetter =
        vehicle.noPlaca.isNotEmpty
            ? vehicle.noPlaca[0].toUpperCase()
            : (
                vehicle.descripcion.isNotEmpty
                    ? vehicle.descripcion[0].toUpperCase()
                    : 'V'
              );

    return CollectionItemData(
      header: CollectionHeaderData(
        title: typeName,
        subtitle: 'ID ${vehicle.id}',
        backgroundColor: AppColors.primary.withOpacity(0.05),
        leadingIcon: Icons.directions_car_filled_outlined,
      ),
      badge: CollectionBadgeData(text: badgeLetter),
      title: vehicle.noPlaca,
      subtitle: vehicle.descripcion,
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
          icon: Icons.badge_outlined,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primary.withOpacity(0.14),
        ),
        CollectionDetailInfo(
          label: 'Modelo',
          value: modelName,
          inlineValue: modelName,
          icon: Icons.precision_manufacturing_outlined,
          iconColor: AppColors.secondary,
          iconBackground: AppColors.secondary.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Combustible',
          value: fuelName,
          inlineValue: fuelName,
          icon: Icons.local_gas_station_outlined,
          iconColor: AppColors.warning,
          iconBackground: AppColors.warning.withOpacity(0.18),
        ),
        CollectionDetailInfo(
          label: 'Chasis',
          value: vehicle.noChasis,
          inlineValue: '',
          icon: Icons.confirmation_num_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Motor',
          value: vehicle.noMotor,
          inlineValue: '',
          icon: Icons.settings_input_component_outlined,
          iconColor: AppColors.grayDark,
          iconBackground: AppColors.grayDark.withOpacity(0.12),
        ),
      ],
      actions: [
        CollectionActionData(
          label: 'Editar',
          icon: Icons.edit_outlined,
          variant: CollectionActionVariant.primary,
          onPressed:
              () => _openVehicleDialog(
                context,
                vehicleProvider,
                typeProvider,
                brandProvider,
                modelProvider,
                fuelProvider,
                initial: vehicle,
              ),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => vehicleProvider.eliminarVehiculo(vehicle.id!),
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
