import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final TextInputType? keyboardType;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final bool? enabled;
  final Widget? suffixIcon;
  final String? initialValue;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool validateOnChange;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.controller,
    this.enabled,
    this.initialValue,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.validateOnChange = true,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  String? _currentError;

  void _validateField(String value) {
    if (widget.validator != null && widget.validateOnChange) {
      final error = widget.validator!(value);
      setState(() {
        _currentError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: widget.suffixIcon,
        errorText: widget.validateOnChange ? _currentError : null,
      ),
      validator: widget.validator,
      onChanged: (value) {
        final trimmed = value.trim();
        widget.onChanged?.call(trimmed);
        _validateField(trimmed);
      },
      inputFormatters: widget.inputFormatters,
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      enabled: widget.enabled,
    );
  }
}
