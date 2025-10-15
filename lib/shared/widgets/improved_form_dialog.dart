import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Tipo de campo de formulario mejorado
enum ImprovedFieldType {
  text,
  email,
  phone,
  number,
  password,
  multiline,
  dropdown,
  switchType,
  date,
  time,
  dateTime,
  checkbox,
}

/// Definición de campo de formulario mejorado
class ImprovedFormField<T> {
  const ImprovedFormField({
    required this.name,
    required this.label,
    this.type = ImprovedFieldType.text,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.required = false,
    this.placeholder,
    this.helperText,
    this.prefix,
    this.suffix,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.dropdownItems = const [],
    this.onChanged,
    this.formatValue,
    this.parseValue,
    this.dependsOn,
    this.showWhen,
    this.keyboardType,
    this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.fillColor,
  });

  final String name;
  final String label;
  final ImprovedFieldType type;
  final dynamic initialValue;
  final String? Function(dynamic)? validator;
  final bool enabled;
  final bool required;
  final String? placeholder;
  final String? helperText;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final List<DropdownMenuItem<dynamic>> dropdownItems;
  final void Function(dynamic)? onChanged;
  final String Function(dynamic)? formatValue;
  final dynamic Function(String)? parseValue;
  final String? dependsOn;
  final bool Function(Map<String, dynamic>)? showWhen;
  final TextInputType? keyboardType;
  final IconData? icon;
  final bool obscureText;
  final bool readOnly;
  final Color? fillColor;
}

/// Resultado del formulario mejorado
class ImprovedFormResult<T> {
  const ImprovedFormResult({
    required this.data,
    required this.isValid,
    this.errors = const {},
  });

  final T data;
  final bool isValid;
  final Map<String, String> errors;
}

/// Diálogo de formulario mejorado y más fluido
class ImprovedFormDialog<T> extends StatefulWidget {
  const ImprovedFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.initialData,
    this.onCancel,
    this.saveButtonText = 'Guardar',
    this.cancelButtonText = 'Cancelar',
    this.width,
    this.height,
    this.scrollable = true,
    this.showProgress = false,
    this.validateOnChange = true,
    this.autoFocus = true,
    this.spacing = 16.0,
    this.headerColor,
    this.successMessage,
    this.loadingMessage = 'Guardando...',
  });

  final String title;
  final List<ImprovedFormField> fields;
  final Future<T?> Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;
  final VoidCallback? onCancel;
  final String saveButtonText;
  final String cancelButtonText;
  final double? width;
  final double? height;
  final bool scrollable;
  final bool showProgress;
  final bool validateOnChange;
  final bool autoFocus;
  final double spacing;
  final Color? headerColor;
  final String? successMessage;
  final String loadingMessage;

  @override
  State<ImprovedFormDialog<T>> createState() => _ImprovedFormDialogState<T>();
}

class _ImprovedFormDialogState<T> extends State<ImprovedFormDialog<T>>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final Map<String, String> _errors = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  bool _isLoading = false;
  bool _isDirty = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _initializeForm();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _initializeForm() {
    for (final field in widget.fields) {
      final initialValue = widget.initialData?[field.name] ?? field.initialValue;
      _values[field.name] = initialValue;

      if (field.type != ImprovedFieldType.switchType &&
          field.type != ImprovedFieldType.checkbox) {
        final controller = TextEditingController(
          text: field.formatValue?.call(initialValue) ?? initialValue?.toString() ?? '',
        );
        _controllers[field.name] = controller;

        controller.addListener(() {
          _onValueChanged(field.name, controller.text);
        });
      }

      _focusNodes[field.name] = FocusNode();
    }

    // Auto-focus primer campo si está habilitado
    if (widget.autoFocus && widget.fields.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[widget.fields.first.name]?.requestFocus();
      });
    }
  }

  void _onValueChanged(String fieldName, dynamic value) {
    setState(() {
      _values[fieldName] = value;
      _isDirty = true;

      if (widget.validateOnChange) {
        _validateField(fieldName);
      }
    });
  }

  void _validateField(String fieldName) {
    final field = widget.fields.firstWhere((f) => f.name == fieldName);
    final value = _values[fieldName];

    String? error;

    // Validación de campo requerido
    if (field.required && (value == null || value.toString().trim().isEmpty)) {
      error = '${field.label} es requerido';
    }

    // Validación personalizada
    if (error == null && field.validator != null) {
      error = field.validator!(value);
    }

    setState(() {
      if (error != null) {
        _errors[fieldName] = error;
      } else {
        _errors.remove(fieldName);
      }
    });
  }

  bool _validateForm() {
    _errors.clear();

    for (final field in widget.fields) {
      _validateField(field.name);
    }

    return _errors.isEmpty;
  }

  Future<void> _handleSave() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.onSave(_values);

      if (widget.successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (_isDirty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text(
            'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel?.call();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Salir'),
            ),
          ],
        ),
      );
    } else {
      widget.onCancel?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = widget.width ?? (screenSize.width * 0.9).clamp(400.0, 600.0);
    final dialogHeight = widget.height ?? screenSize.height * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.headerColor ?? AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.grayLight.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                if (_isDirty)
                  Text(
                    'Modificado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _handleCancel,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.grayDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final content = Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            for (int i = 0; i < widget.fields.length; i++) ...[
              if (i > 0) SizedBox(height: widget.spacing),
              _buildField(widget.fields[i]),
            ],
          ],
        ),
      ),
    );

    if (widget.scrollable) {
      return SingleChildScrollView(child: content);
    }

    return content;
  }

  Widget _buildField(ImprovedFormField field) {
    // Verificar dependencias
    if (field.showWhen != null && !field.showWhen!(_values)) {
      return const SizedBox.shrink();
    }

    switch (field.type) {
      case ImprovedFieldType.switchType:
        return _buildSwitchField(field);
      case ImprovedFieldType.checkbox:
        return _buildCheckboxField(field);
      case ImprovedFieldType.dropdown:
        return _buildDropdownField(field);
      case ImprovedFieldType.date:
      case ImprovedFieldType.time:
      case ImprovedFieldType.dateTime:
        return _buildDateTimeField(field);
      default:
        return _buildTextFormField(field);
    }
  }

  Widget _buildTextFormField(ImprovedFormField field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      enabled: field.enabled,
      readOnly: field.readOnly,
      obscureText: field.obscureText,
      keyboardType: field.keyboardType ?? _getKeyboardType(field.type),
      maxLength: field.maxLength,
      minLines: field.minLines,
      maxLines: field.maxLines,
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        hintText: field.placeholder,
        helperText: field.helperText,
        errorText: _errors[field.name],
        prefixIcon: field.icon != null
            ? Icon(field.icon, color: AppColors.primary)
            : field.prefix,
        suffixIcon: field.suffix,
        filled: true,
        fillColor: field.fillColor ?? AppColors.light.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.grayLight.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 2,
          ),
        ),
      ),
      onChanged: (value) {
        final parsedValue = field.parseValue?.call(value) ?? value;
        _onValueChanged(field.name, parsedValue);
        field.onChanged?.call(parsedValue);
      },
    );
  }

  Widget _buildSwitchField(ImprovedFormField field) {
    return Row(
      children: [
        if (field.icon != null) ...[
          Icon(field.icon, color: AppColors.primary),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            field.label + (field.required ? ' *' : ''),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: _values[field.name] ?? false,
          onChanged: field.enabled
              ? (value) {
                  _onValueChanged(field.name, value);
                  field.onChanged?.call(value);
                }
              : null,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildCheckboxField(ImprovedFormField field) {
    return CheckboxListTile(
      title: Text(field.label + (field.required ? ' *' : '')),
      subtitle: field.helperText != null ? Text(field.helperText!) : null,
      value: _values[field.name] ?? false,
      onChanged: field.enabled
          ? (value) {
              _onValueChanged(field.name, value ?? false);
              field.onChanged?.call(value ?? false);
            }
          : null,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownField(ImprovedFormField field) {
    return DropdownButtonFormField<dynamic>(
      value: _values[field.name],
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        hintText: field.placeholder,
        helperText: field.helperText,
        errorText: _errors[field.name],
        prefixIcon: field.icon != null
            ? Icon(field.icon, color: AppColors.primary)
            : field.prefix,
        filled: true,
        fillColor: field.fillColor ?? AppColors.light.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.grayLight.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      items: field.dropdownItems,
      onChanged: field.enabled
          ? (value) {
              _onValueChanged(field.name, value);
              field.onChanged?.call(value);
            }
          : null,
    );
  }

  Widget _buildDateTimeField(ImprovedFormField field) {
    final controller = _controllers[field.name]!;

    return TextFormField(
      controller: controller,
      focusNode: _focusNodes[field.name],
      enabled: field.enabled,
      readOnly: true,
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        hintText: field.placeholder,
        helperText: field.helperText,
        errorText: _errors[field.name],
        prefixIcon: Icon(
          field.type == ImprovedFieldType.date
              ? Icons.calendar_today
              : field.type == ImprovedFieldType.time
                  ? Icons.access_time
                  : Icons.event,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: field.fillColor ?? AppColors.light.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () => _selectDateTime(field),
    );
  }

  Future<void> _selectDateTime(ImprovedFormField field) async {
    final now = DateTime.now();
    final initialDate = _values[field.name] is DateTime
        ? _values[field.name] as DateTime
        : now;

    switch (field.type) {
      case ImprovedFieldType.date:
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          _onValueChanged(field.name, date);
          _controllers[field.name]!.text = '${date.day}/${date.month}/${date.year}';
        }
        break;

      case ImprovedFieldType.time:
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate),
        );
        if (time != null) {
          final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
          _onValueChanged(field.name, dateTime);
          _controllers[field.name]!.text = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        }
        break;

      case ImprovedFieldType.dateTime:
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null && mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDate),
          );
          if (time != null) {
            final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            _onValueChanged(field.name, dateTime);
            _controllers[field.name]!.text =
                '${date.day}/${date.month}/${date.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
          }
        }
        break;

      default:
        break;
    }
  }

  TextInputType? _getKeyboardType(ImprovedFieldType type) {
    switch (type) {
      case ImprovedFieldType.email:
        return TextInputType.emailAddress;
      case ImprovedFieldType.phone:
        return TextInputType.phone;
      case ImprovedFieldType.number:
        return TextInputType.number;
      case ImprovedFieldType.multiline:
        return TextInputType.multiline;
      default:
        return null;
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.light.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: AppColors.grayLight.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.showProgress && _isLoading)
            const CircularProgressIndicator(strokeWidth: 2),
          if (widget.showProgress && _isLoading)
            const SizedBox(width: 16),
          if (widget.showProgress && _isLoading)
            Text(
              widget.loadingMessage,
              style: TextStyle(color: AppColors.grayDark),
            ),
          const Spacer(),
          OutlinedButton(
            onPressed: _isLoading ? null : _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.cancelButtonText),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _isLoading ? null : _handleSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.saveButtonText),
          ),
        ],
      ),
    );
  }
}