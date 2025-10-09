import 'package:flutter/material.dart';
import '../../core/services/validation_service.dart';
import '../../core/constants/app_constants.dart';

/// Widget mejorado para campos de texto con validación integrada
class ValidatedTextFormField extends StatelessWidget {
  final String labelText;
  final String? helperText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;

  const ValidatedTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: labelText,
            helperText: helperText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Formulario específico para proveedores con validaciones robustas
class SupplierFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? initialData;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const SupplierFormDialog({
    super.key,
    required this.title,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaRncController = TextEditingController();
  final _nombreComercialController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _cedulaRncController.text = widget.initialData!['cedulaRnc'] ?? '';
      _nombreComercialController.text =
          widget.initialData!['nombreComercial'] ?? '';
      _direccionController.text = widget.initialData!['direccion'] ?? '';
      _telefonoController.text = widget.initialData!['telefono'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _isActive = widget.initialData!['isActive'] ?? true;
    }
  }

  @override
  void dispose() {
    _cedulaRncController.dispose();
    _nombreComercialController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'cedulaRnc': _cedulaRncController.text.trim(),
        'nombreComercial': _nombreComercialController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        'isActive': _isActive,
        if (widget.initialData != null) 'id': widget.initialData!['id'],
      };

      await widget.onSubmit(data);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(
          maxWidth: AppConstants.maxDialogWidth,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ValidatedTextFormField(
                        labelText: 'Cédula/RNC *',
                        controller: _cedulaRncController,
                        keyboardType: TextInputType.number,
                        helperText: 'Ingrese 11 dígitos',
                        validator: ValidationService.validateCedulaRnc,
                      ),
                      const SizedBox(height: 16),
                      ValidatedTextFormField(
                        labelText: 'Nombre Comercial *',
                        controller: _nombreComercialController,
                        helperText: 'Nombre de la empresa o persona',
                        validator:
                            (value) => ValidationService.validateRequired(
                              value,
                              'Nombre comercial',
                            ),
                      ),
                      const SizedBox(height: 16),
                      ValidatedTextFormField(
                        labelText: 'Dirección *',
                        controller: _direccionController,
                        maxLines: 2,
                        helperText: 'Dirección completa del proveedor',
                        validator:
                            (value) => ValidationService.validateRequired(
                              value,
                              'Dirección',
                            ),
                      ),
                      const SizedBox(height: 16),
                      ValidatedTextFormField(
                        labelText: 'Teléfono',
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        helperText: 'Número de contacto (opcional)',
                        validator: ValidationService.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      ValidatedTextFormField(
                        labelText: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        helperText: 'Correo electrónico (opcional)',
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          return ValidationService.validateEmail(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Activo'),
                        subtitle: const Text('¿El proveedor está activo?'),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              widget.initialData != null
                                  ? 'Actualizar'
                                  : 'Crear',
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
