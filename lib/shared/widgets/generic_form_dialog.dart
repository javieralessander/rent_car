import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenericFormDialog<T> extends StatefulWidget {
  final String title;
  final T? initialData;
  final List<FormFieldDefinition<T>> fields;
  final Future<void> Function(T data) onSubmit;
  final T Function(Map<String, dynamic> values, T? initialData) fromValues;
  final double?
  dialogWidthFactor; // Factor del ancho de pantalla (ej: 0.6 para 60%)
  final double?
  dialogHeightFactor; // Factor del alto de pantalla (ej: 0.8 para 80%)
  final double? maxWidth; // Ancho máximo absoluto
  final double? maxHeight; // Alto máximo absoluto

  const GenericFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.fromValues,
    this.initialData,
    this.dialogWidthFactor,
    this.dialogHeightFactor,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<GenericFormDialog<T>> createState() => _GenericFormDialogState<T>();
}

class _GenericFormDialogState<T> extends State<GenericFormDialog<T>> {
  final Map<String, dynamic> _formValues = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _formValues[field.key] = field.getValue(widget.initialData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calcular el ancho del diálogo
    double dialogWidth;
    if (widget.dialogWidthFactor != null) {
      dialogWidth = screenSize.width * widget.dialogWidthFactor!;
      if (widget.maxWidth != null) {
        dialogWidth = dialogWidth.clamp(0, widget.maxWidth!);
      }
    } else {
      // Valor por defecto
      dialogWidth =
          screenSize.width > 1200
              ? screenSize.width *
                  0.6 // 60% en pantallas grandes
              : screenSize.width > 800
              ? screenSize.width *
                  0.75 // 75% en pantallas medianas
              : screenSize.width * 0.9; // 90% en pantallas pequeñas
    }

    // Calcular la altura del diálogo
    double? dialogHeight;
    if (widget.dialogHeightFactor != null) {
      dialogHeight = screenSize.height * widget.dialogHeightFactor!;
      if (widget.maxHeight != null) {
        dialogHeight = dialogHeight.clamp(0, widget.maxHeight!);
      }
    }

    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: field.buildField(
                        context,
                        _formValues[field.key],
                        (value) =>
                            setState(() => _formValues[field.key] = value),
                        widget.initialData,
                        _formValues,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final data = widget.fromValues(_formValues, widget.initialData);
              await widget.onSubmit(data);
              if (context.mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Guardar', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

class FormFieldDefinition<T> {
  final String key;
  final String label;
  final String fieldType; // 'text' | 'dropdown' | 'number' | 'custom'
  final List<dynamic>? options;
  final dynamic Function(T?) getValue;
  final T? Function(T?, dynamic) applyValue;
  final String? Function(dynamic)? validator;
  final String Function(dynamic)? display;
  final Widget Function(
    BuildContext context,
    _FormFieldController controller,
    T? initialData,
    Map<String, dynamic>? formValues,
  )?
  builder; // <-- Agregado
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int? maxLength;
  final String? hintText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? textValidator;

  FormFieldDefinition({
    required this.key,
    required this.label,
    required this.getValue,
    required this.applyValue,
    this.fieldType = 'text',
    this.options,
    this.validator,
    this.display,
    this.builder, // <-- Agregado
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLength,
    this.hintText,
    this.textInputAction,
    this.textValidator,
  });

  Widget buildField(
    BuildContext context,
    dynamic value,
    Function(dynamic) onChanged, [
    T? initialData,
    Map<String, dynamic>? formValues,
  ]) {
    if (fieldType == 'custom' && builder != null) {
      return builder!(
        context,
        _FormFieldController(value: value, setValue: onChanged),
        initialData,
        formValues,
      );
    }
    switch (fieldType) {
      case 'dropdown':
        // Create dropdown items and remove duplicates
        final dropdownItems = <DropdownMenuItem<dynamic>>[];
        final seenValues = <dynamic>{};

        for (final opt in options!) {
          final itemValue = opt is Map ? opt['value'] : opt;
          if (!seenValues.contains(itemValue)) {
            seenValues.add(itemValue);
            dropdownItems.add(DropdownMenuItem<dynamic>(
              value: itemValue,
              child: Text(
                display != null
                    ? display!(opt)
                    : opt is Map
                    ? opt['label'].toString()
                    : opt.toString(),
              ),
            ));
          }
        }

        // Ensure initial value exists in the options
        final validInitialValue = seenValues.contains(value) ? value : (seenValues.isNotEmpty ? seenValues.first : null);

        return DropdownButtonFormField<dynamic>(
          value: validInitialValue,
          decoration: InputDecoration(labelText: label),
          items: dropdownItems,
          onChanged: (newValue) {
            // If we had to change the initial value due to validation,
            // make sure to call onChanged with the corrected value
            if (validInitialValue != value && validInitialValue != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onChanged?.call(validInitialValue);
              });
            }
            onChanged?.call(newValue);
          },
          validator: (raw) {
            if (validator != null) {
              return validator!(raw);
            }
            return null;
          },
        );
      case 'number':
        return TextFormField(
          initialValue: value?.toString(),
          decoration: InputDecoration(labelText: label, hintText: hintText),
          keyboardType:
              keyboardType ??
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: inputFormatters,
          textInputAction: textInputAction ?? TextInputAction.next,
          onChanged: (v) {
            final trimmed = v.trim();
            if (trimmed.isEmpty) {
              onChanged(null);
              return;
            }
            final normalized = trimmed.replaceAll(',', '.');
            final parsed = double.tryParse(normalized);
            if (parsed == null) {
              onChanged(null);
            } else if (parsed % 1 == 0) {
              onChanged(parsed.toInt());
            } else {
              onChanged(parsed);
            }
          },
          validator: validator,
        );
      case 'date':
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: label),
            child: Text(
              value != null
                  ? (value is DateTime
                      ? value.toIso8601String().split('T').first
                      : value.toString())
                  : '',
            ),
          ),
        );
      default:
        return TextFormField(
          initialValue: value is String ? value : value?.toString(),
          decoration: InputDecoration(labelText: label, hintText: hintText),
          textCapitalization: textCapitalization,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          textInputAction: textInputAction ?? TextInputAction.next,
          onChanged: (v) => onChanged(v.trim()),
          validator: (raw) {
            final trimmed = raw?.trim();
            final textError = textValidator?.call(trimmed);
            if (textError != null) return textError;
            return validator?.call(trimmed);
          },
        );
    }
  }
}

// Controlador para campos personalizados
class _FormFieldController {
  dynamic value;
  final void Function(dynamic) setValue;
  _FormFieldController({required this.value, required this.setValue});
}
