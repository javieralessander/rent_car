import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_collection_view.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/utils/input_validators.dart';
import '../../../../shared/widgets/status_widget.dart';
import '../models/client_model.dart';
import '../providers/client_provider.dart';

class ClientScreen extends StatefulWidget {
  static const String name = 'clients';
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  CollectionViewMode _viewMode = CollectionViewMode.grid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().cargarClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericCollectionView(
        title: 'Lista de clientes',
        isLoading: provider.isLoading,
        items: provider.clientes
            .map((cliente) => _buildClientItem(context, cliente))
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
          onPressed: () => _openClientDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar cliente'),
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

  Future<void> _openClientDialog(
    BuildContext context, {
    Client? initial,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => GenericFormDialog<Client>(
        title: initial == null ? 'Agregar Cliente' : 'Editar Cliente',
        initialData: initial,
        onSubmit: (data) async {
          if (initial == null) {
            await context.read<ClientProvider>().agregarCliente(data);
          } else {
            await context.read<ClientProvider>().actualizarCliente(data);
          }
        },
        fromValues: (values, previous) => Client(
          id: previous?.id ?? initial?.id ?? 0,
          nombre: values['nombre'] ?? previous?.nombre ?? initial?.nombre ?? '',
          cedula: values['cedula'] ?? previous?.cedula ?? initial?.cedula ?? '',
          noTarjetaCr: values['noTarjetaCr'] ??
              previous?.noTarjetaCr ?? initial?.noTarjetaCr ?? '',
          limiteCredito: _parseDouble(values['limiteCredito']) ??
              previous?.limiteCredito ?? initial?.limiteCredito ?? 0.0,
          tipoPersona: values['tipoPersona'] ??
              previous?.tipoPersona ?? initial?.tipoPersona ?? TipoPersona.FISICA,
          estado: values['estado'] ?? previous?.estado ?? initial?.estado ?? true,
        ),
        fields: [
          // 1. Nombre
          FormFieldDefinition<Client>(
            key: 'nombre',
            label: 'Nombre',
            textValidator: (value) => InputValidators.requiredText(
              value,
              fieldName: 'Nombre',
            ),
            inputFormatters: InputFormatters.names(maxLength: 60),
            textCapitalization: TextCapitalization.words,
            getValue: (v) => v?.nombre ?? '',
            applyValue: (v, value) => Client(
              id: v?.id ?? initial?.id ?? 0,
              nombre: value,
              cedula: v?.cedula ?? initial?.cedula ?? '',
              noTarjetaCr: v?.noTarjetaCr ?? initial?.noTarjetaCr ?? '',
              limiteCredito: v?.limiteCredito ?? initial?.limiteCredito ?? 0.0,
              tipoPersona: v?.tipoPersona ?? initial?.tipoPersona ?? TipoPersona.FISICA,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          // 2. Tipo de Persona (PRIMERO para cambiar validación)
          FormFieldDefinition<Client>(
            key: 'tipoPersona',
            label: 'Tipo de Persona',
            fieldType: 'dropdown',
            options: const [
              {'value': TipoPersona.FISICA, 'label': 'Física'},
              {'value': TipoPersona.JURIDICA, 'label': 'Jurídica'},
            ],
            validator: (value) {
              if (value == null) {
                return 'Tipo de persona es requerido';
              }
              return null;
            },
            getValue: (v) => v?.tipoPersona,
            applyValue: (v, value) => Client(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              noTarjetaCr: v?.noTarjetaCr ?? initial?.noTarjetaCr ?? '',
              limiteCredito: v?.limiteCredito ?? initial?.limiteCredito ?? 0.0,
              tipoPersona: value as TipoPersona,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          // 3. Cédula/RNC (con validación dinámica basada en Tipo de Persona)
          FormFieldDefinition<Client>(
            key: 'cedula',
            label: 'Cédula/RNC',
            fieldType: 'custom',
            getValue: (v) => v?.cedula ?? '',
            applyValue: (v, value) => Client(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: value,
              noTarjetaCr: v?.noTarjetaCr ?? initial?.noTarjetaCr ?? '',
              limiteCredito: v?.limiteCredito ?? initial?.limiteCredito ?? 0.0,
              tipoPersona: v?.tipoPersona ?? initial?.tipoPersona ?? TipoPersona.FISICA,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
            builder: (context, controller, initialData, formValues) {
              return _buildDynamicCedulaField(context, controller, initialData, formValues);
            },
          ),
          // 4. No. Tarjeta CR (con ícono dinámico)
          FormFieldDefinition<Client>(
            key: 'noTarjetaCr',
            label: 'No. Tarjeta CR',
            fieldType: 'custom',
            getValue: (v) => v?.noTarjetaCr ?? '',
            applyValue: (v, value) => Client(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              noTarjetaCr: value,
              limiteCredito: v?.limiteCredito ?? initial?.limiteCredito ?? 0.0,
              tipoPersona: v?.tipoPersona ?? initial?.tipoPersona ?? TipoPersona.FISICA,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
            builder: (context, controller, initialData, formValues) {
              return _buildDynamicCreditCardField(context, controller, initialData);
            },
          ),
          // 5. Límite de Crédito
          FormFieldDefinition<Client>(
            key: 'limiteCredito',
            label: 'Límite de Crédito',
            fieldType: 'decimal',
            textValidator: (value) => InputValidators.requiredDecimal(
              value,
              fieldName: 'Límite de Crédito',
              minValue: 0.0,
            ),
            getValue: (v) => v?.limiteCredito,
            applyValue: (v, value) => Client(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              noTarjetaCr: v?.noTarjetaCr ?? initial?.noTarjetaCr ?? '',
              limiteCredito: value as double,
              tipoPersona: v?.tipoPersona ?? initial?.tipoPersona ?? TipoPersona.FISICA,
              estado: v?.estado ?? initial?.estado ?? true,
            ),
          ),
          // 6. Estado
          FormFieldDefinition<Client>(
            key: 'estado',
            label: 'Estado',
            fieldType: 'dropdown',
            options: const [
              {'value': true, 'label': 'Activo'},
              {'value': false, 'label': 'Inactivo'},
            ],
            getValue: (v) => v?.estado,
            applyValue: (v, value) => Client(
              id: v?.id ?? initial?.id ?? 0,
              nombre: v?.nombre ?? initial?.nombre ?? '',
              cedula: v?.cedula ?? initial?.cedula ?? '',
              noTarjetaCr: v?.noTarjetaCr ?? initial?.noTarjetaCr ?? '',
              limiteCredito: v?.limiteCredito ?? initial?.limiteCredito ?? 0.0,
              tipoPersona: v?.tipoPersona ?? initial?.tipoPersona ?? TipoPersona.FISICA,
              estado: value as bool,
            ),
          ),
        ],
      ),
    );
  }

  CollectionItemData _buildClientItem(
    BuildContext context,
    Client cliente,
  ) {
    final isActive = cliente.estado;
    final initials = cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : 'C';
    final tipoPersonaText = cliente.tipoPersona == TipoPersona.FISICA ? 'Persona Física' : 'Persona Jurídica';

    return CollectionItemData(
      header: CollectionHeaderData(
        title: tipoPersonaText,
        subtitle: cliente.cedula,
        backgroundColor: AppColors.primary.withOpacity(0.05),
        leadingIcon: cliente.tipoPersona == TipoPersona.FISICA ? Icons.person : Icons.business,
      ),
      badge: CollectionBadgeData(text: initials),
      title: cliente.nombre,
      subtitle: '$tipoPersonaText • Cédula: ${cliente.cedula}',
      statusChip: CollectionStatusChip(
        label: isActive ? 'Activo' : 'Inactivo',
        backgroundColor: isActive ? AppColors.success.withOpacity(0.16) : AppColors.grayLight.withOpacity(0.45),
        textColor: isActive ? AppColors.success : AppColors.grayDark,
      ),
      details: [
        CollectionDetailInfo(
          label: 'Identificador',
          value: '#${cliente.id}',
          inlineValue: 'ID ${cliente.id}',
          icon: Icons.confirmation_number_outlined,
        ),
        CollectionDetailInfo(
          label: 'Cédula',
          value: cliente.cedula,
          inlineValue: cliente.cedula,
          icon: Icons.credit_card_outlined,
        ),
        CollectionDetailInfo(
          label: 'Tipo Persona',
          value: tipoPersonaText,
          inlineValue: tipoPersonaText,
          icon: cliente.tipoPersona == TipoPersona.FISICA ? Icons.person : Icons.business,
        ),
        CollectionDetailInfo(
          label: 'Límite Crédito',
          value: InputFormatters.formatCurrency(cliente.limiteCredito),
          inlineValue: InputFormatters.formatCurrency(cliente.limiteCredito),
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
      actions: [
        CollectionActionData(
          label: 'Editar',
          icon: Icons.edit_outlined,
          variant: CollectionActionVariant.primary,
          onPressed: () => _openClientDialog(context, initial: cliente),
        ),
        CollectionActionData(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          variant: CollectionActionVariant.danger,
          onPressed: () => ConfirmationDialog.showDeleteDialog(
            context: context,
            title: 'Eliminar Cliente',
            itemName: cliente.nombre,
            additionalInfo: 'Se eliminará permanentemente del sistema junto con su historial.',
            onConfirm: () => context.read<ClientProvider>().eliminarCliente(cliente.id!),
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

  /// Helper method to safely parse double values from form
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Helper method to get credit card icon
  /// Usage example: CreditCardUtils.getCardIcon(CreditCardUtils.detectCardType(cardNumber))
  Widget _getCreditCardIcon(String cardNumber) {
    final cardType = CreditCardUtils.detectCardType(cardNumber);
    return CreditCardUtils.getCardIcon(cardType);
  }

  /// Builds a dynamic credit card field that shows card type icon in real-time
  Widget _buildDynamicCreditCardField(
    BuildContext context,
    controller,
    Client? initialData,
  ) {
    return _CreditCardFieldWidget(
      controller: controller,
      initialValue: controller.value ?? '',
    );
  }

  /// Builds a dynamic Cédula/RNC field that changes validation and formatting
  /// based on the selected Tipo de Persona
  Widget _buildDynamicCedulaField(
    BuildContext context,
    controller,
    Client? initialData,
    Map<String, dynamic>? formValues,
  ) {
    return _DynamicCedulaFieldWidget(
      controller: controller,
      initialData: initialData,
      formValues: formValues,
    );
  }
}

/// Widget separado para manejar el campo de cédula/RNC con validación en tiempo real
class _DynamicCedulaFieldWidget extends StatefulWidget {
  final dynamic controller;
  final Client? initialData;
  final Map<String, dynamic>? formValues;

  const _DynamicCedulaFieldWidget({
    required this.controller,
    required this.initialData,
    required this.formValues,
  });

  @override
  State<_DynamicCedulaFieldWidget> createState() => _DynamicCedulaFieldWidgetState();
}

class _DynamicCedulaFieldWidgetState extends State<_DynamicCedulaFieldWidget> {
  late TextEditingController _textController;
  String? _currentError;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.value ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _validateField(String value) {
    final currentTipoPersona = widget.formValues?['tipoPersona'] as TipoPersona? ??
        widget.initialData?.tipoPersona ??
        TipoPersona.FISICA;

    final isPersonaFisica = currentTipoPersona == TipoPersona.FISICA;
    final fieldLabel = isPersonaFisica ? 'Cédula' : 'RNC';

    String? error;

    if ((value.trim()).isEmpty) {
      error = '$fieldLabel es requerido';
    } else {
      if (isPersonaFisica) {
        error = InputValidators.cedulaDominicana(value, fieldName: fieldLabel);
      } else {
        error = InputValidators.rncDominicano(value, fieldName: fieldLabel);
      }
    }

    setState(() {
      _currentError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTipoPersona = widget.formValues?['tipoPersona'] as TipoPersona? ??
        widget.initialData?.tipoPersona ??
        TipoPersona.FISICA;

    final isPersonaFisica = currentTipoPersona == TipoPersona.FISICA;
    final fieldLabel = isPersonaFisica ? 'Cédula' : 'RNC';
    final fieldHint = isPersonaFisica ? 'XXX-XXXXXXX-X' : 'XXXXXXXXX';

    return TextFormField(
      key: ValueKey('${fieldLabel}_${currentTipoPersona.name}'),
      controller: _textController,
      decoration: InputDecoration(
        labelText: fieldLabel,
        hintText: fieldHint,
        errorText: _currentError,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: isPersonaFisica
        ? InputFormatters.cedula()
        : InputFormatters.rnc(),
      validator: (value) {
        if ((value?.trim() ?? '').isEmpty) {
          return '$fieldLabel es requerido';
        }

        if (isPersonaFisica) {
          return InputValidators.cedulaDominicana(value, fieldName: fieldLabel);
        } else {
          return InputValidators.rncDominicano(value, fieldName: fieldLabel);
        }
      },
      onChanged: (value) {
        widget.controller.setValue(value);
        _validateField(value);
      },
    );
  }
}

/// Widget separado para manejar el campo de tarjeta de crédito con ícono dinámico
/// sin perder el foco
class _CreditCardFieldWidget extends StatefulWidget {
  final dynamic controller;
  final String initialValue;

  const _CreditCardFieldWidget({
    required this.controller,
    required this.initialValue,
  });

  @override
  State<_CreditCardFieldWidget> createState() => _CreditCardFieldWidgetState();
}

class _CreditCardFieldWidgetState extends State<_CreditCardFieldWidget> {
  late TextEditingController _textController;
  late ValueNotifier<CreditCardType> _cardTypeNotifier;
  String? _currentError;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
    _cardTypeNotifier = ValueNotifier(CreditCardUtils.detectCardType(widget.initialValue));
  }

  @override
  void dispose() {
    _textController.dispose();
    _cardTypeNotifier.dispose();
    super.dispose();
  }

  void _updateCardType(String value) {
    final newCardType = CreditCardUtils.detectCardType(value);
    if (newCardType != _cardTypeNotifier.value) {
      _cardTypeNotifier.value = newCardType;
    }
  }

  void _validateField(String value) {
    final error = InputValidators.creditCard(value, fieldName: 'No. Tarjeta CR');
    setState(() {
      _currentError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // TextField sin suffixIcon para evitar rebuilds
        TextFormField(
          key: _fieldKey,
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'No. Tarjeta CR',
            hintText: 'XXXX XXXX XXXX XXXX',
            contentPadding: const EdgeInsets.fromLTRB(12, 16, 48, 16), // Espacio para el ícono
            errorText: _currentError,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: InputFormatters.cardNumber(),
          validator: (value) => InputValidators.creditCard(
            value,
            fieldName: 'No. Tarjeta CR',
          ),
          onChanged: (value) {
            widget.controller.setValue(value);
            _updateCardType(value);
            _validateField(value);
          },
        ),
        // Ícono flotante que se actualiza independientemente
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: ValueListenableBuilder<CreditCardType>(
            valueListenable: _cardTypeNotifier,
            builder: (context, cardType, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _textController.text.isNotEmpty && cardType != CreditCardType.unknown
                  ? Container(
                      key: ValueKey(cardType),
                      width: 32,
                      height: 20,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: CreditCardUtils.getCardIcon(cardType, width: 32, height: 20),
                    )
                  : const SizedBox(width: 32, height: 20),
              );
            },
          ),
        ),
      ],
    );
  }
}