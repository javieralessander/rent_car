import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        isDense: true,
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: onChanged != null ? (value) => onChanged!(value.trim()) : null,
      inputFormatters: inputFormatters,
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      textInputAction: textInputAction,
      onTap: onTap,
      enabled: enabled,
    );
  }
}
