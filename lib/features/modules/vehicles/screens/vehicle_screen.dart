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
                typeMap[vehicle.tipoVehiculo] ?? 'Tipo ${vehicle.tipoVehiculo}',
                brandMap[vehicle.marca] ?? 'Marca ${vehicle.marca}',
                modelMap[vehicle.modelo] ?? 'Modelo ${vehicle.modelo}',
                fuelMap[vehicle.tipoCombustible] ??
                    'Combustible ${vehicle.tipoCombustible}',
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
      builder: (_) => GenericFormDialog<Vehicle>(
        title: initial == null ? 'Agregar vehículo' : 'Editar vehículo',
        initialData: initial,
        onSubmit: (data) async {
          if (initial == null) {
            await vehicleProvider.agregarVehiculo(data);
          } else {
            await vehicleProvider.actualizarVehiculo(data);
          }
        },
        fromValues: (values, previous) => Vehicle(
          id: previous?.id ?? initial?.id ?? 0,
          descripcion: values['descripcion'] ?? previous?.descripcion ?? initial?.descripcion ?? '',
          numeroChasis: values['numeroChasis'] ?? previous?.numeroChasis ?? initial?.numeroChasis ?? '',
          numeroMotor: values['numeroMotor'] ?? previous?.numeroMotor ?? initial?.numeroMotor ?? '',
          numeroPlaca: values['numeroPlaca'] ?? previous?.numeroPlaca ?? initial?.numeroPlaca ?? '',
          tipoVehiculo: values['tipoVehiculo'] ?? previous?.tipoVehiculo ?? initial?.tipoVehiculo ?? typeOptions.first['value'] as int,
          marca: values['marca'] ?? previous?.marca ?? initial?.marca ?? brandOptions.first['value'] as int,
          modelo: values['modelo'] ?? previous?.modelo ?? initial?.modelo ?? modelOptions.first['value'] as int,
          tipoCombustible: values['tipoCombustible'] ?? previous?.tipoCombustible ?? initial?.tipoCombustible ?? fuelOptions.first['value'] as int,
          estado: values['estado'] ?? previous?.estado ?? initial?.estado ?? true,
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

  List<FormFieldDefinition<Vehicle>> _vehicleFormFields({
    required List<Map<String, Object>> typeOptions,
    required List<Map<String, Object>> brandOptions,
    required List<Map<String, Object>> modelOptions,
    required List<Map<String, Object>> fuelOptions,
    Vehicle? initial,
  }) {
    int defaultOption(List<Map<String, Object>> options) =>
        options.first['value'] as int;

    return [
      FormFieldDefinition<Vehicle>(
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
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: value,
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'numeroPlaca',
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
        getValue: (v) => v?.numeroPlaca ?? '',
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: value,
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'numeroChasis',
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
        getValue: (v) => v?.numeroChasis ?? '',
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: value,
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'numeroMotor',
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
        getValue: (v) => v?.numeroMotor ?? '',
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: value,
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'tipoVehiculo',
        label: 'Tipo de vehículo',
        fieldType: 'dropdown',
        options: typeOptions,
        validator: (value) {
          if (value == null) {
            return 'Tipo de vehículo es requerido';
          }
          return null;
        },
        getValue: (v) => v?.tipoVehiculo ?? defaultOption(typeOptions),
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo: value as int,
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'marca',
        label: 'Marca',
        fieldType: 'dropdown',
        options: brandOptions,
        validator: (value) {
          if (value == null) {
            return 'Marca es requerida';
          }
          return null;
        },
        getValue: (v) => v?.marca ?? defaultOption(brandOptions),
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: value as int,
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'modelo',
        label: 'Modelo',
        fieldType: 'dropdown',
        options: modelOptions,
        validator: (value) {
          if (value == null) {
            return 'Modelo es requerido';
          }
          return null;
        },
        getValue: (v) => v?.modelo ?? defaultOption(modelOptions),
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo: value as int,
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'tipoCombustible',
        label: 'Tipo de combustible',
        fieldType: 'dropdown',
        options: fuelOptions,
        validator: (value) {
          if (value == null) {
            return 'Tipo de combustible es requerido';
          }
          return null;
        },
        getValue: (v) => v?.tipoCombustible ?? defaultOption(fuelOptions),
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible: value as int,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
      ),
      FormFieldDefinition<Vehicle>(
        key: 'estado',
        label: 'Estado',
        fieldType: 'dropdown',
        options: const [
          {'value': true, 'label': 'Activo'},
          {'value': false, 'label': 'Inactivo'},
        ],
        getValue: (v) => v?.estado ?? true,
        applyValue:
            (v, value) => Vehicle(
              id: v?.id ?? initial?.id ?? 0,
              descripcion: v?.descripcion ?? initial?.descripcion ?? '',
              numeroChasis: v?.numeroChasis ?? initial?.numeroChasis ?? '',
              numeroMotor: v?.numeroMotor ?? initial?.numeroMotor ?? '',
              numeroPlaca: v?.numeroPlaca ?? initial?.numeroPlaca ?? '',
              tipoVehiculo:
                  v?.tipoVehiculo ??
                  initial?.tipoVehiculo ??
                  defaultOption(typeOptions),
              marca: v?.marca ?? initial?.marca ?? defaultOption(brandOptions),
              modelo:
                  v?.modelo ?? initial?.modelo ?? defaultOption(modelOptions),
              tipoCombustible:
                  v?.tipoCombustible ??
                  initial?.tipoCombustible ??
                  defaultOption(fuelOptions),
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
        vehicle.numeroPlaca.isNotEmpty
            ? vehicle.numeroPlaca[0].toUpperCase()
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
      title: vehicle.numeroPlaca,
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
          value: vehicle.numeroChasis,
          inlineValue: '',
          icon: Icons.confirmation_num_outlined,
          iconColor: AppColors.info,
          iconBackground: AppColors.info.withOpacity(0.16),
        ),
        CollectionDetailInfo(
          label: 'Motor',
          value: vehicle.numeroMotor,
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
          onPressed: () => vehicleProvider.eliminarVehiculo(vehicle.id),
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
