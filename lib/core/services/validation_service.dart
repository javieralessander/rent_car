import '../constants/app_constants.dart';

/// Servicio de validación para formularios
class ValidationService {
  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    if (value.length > AppConstants.maxEmailLength) {
      return 'El email no puede tener más de ${AppConstants.maxEmailLength} caracteres';
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Valida contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no puede tener más de ${AppConstants.maxPasswordLength} caracteres';
    }

    // Validar que tenga al menos una letra y un número
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra y un número';
    }

    return null;
  }

  /// Valida confirmación de contraseña
  static String? validatePasswordConfirm(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirme la contraseña';
    }

    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Valida nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'El nombre no puede tener más de ${AppConstants.maxNameLength} caracteres';
    }

    // Solo letras y espacios
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(value)) {
      return 'El nombre solo puede contener letras y espacios';
    }

    return null;
  }

  /// Valida teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    if (value.length > AppConstants.maxPhoneLength) {
      return 'El teléfono no puede tener más de ${AppConstants.maxPhoneLength} caracteres';
    }

    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingrese un número de teléfono válido';
    }

    return null;
  }

  /// Valida cédula/RNC
  static String? validateCedulaRnc(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula/RNC es requerida';
    }

    final cedulaRegex = RegExp(AppConstants.cedulaRncPattern);
    if (!cedulaRegex.hasMatch(value)) {
      return 'Ingrese una cédula/RNC válida (11 dígitos)';
    }

    return null;
  }

  /// Valida campo requerido genérico
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Valida número positivo
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }

    if (number <= 0) {
      return '$fieldName debe ser un número positivo';
    }

    return null;
  }

  /// Valida entero positivo
  static String? validatePositiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número entero válido';
    }

    if (number <= 0) {
      return '$fieldName debe ser un número entero positivo';
    }

    return null;
  }

  /// Valida longitud mínima
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Valida longitud máxima
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede tener más de $maxLength caracteres';
    }

    return null;
  }

  /// Valida descripción genérica
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es requerida';
    }

    if (value.length < 2) {
      return 'La descripción debe tener al menos 2 caracteres';
    }

    if (value.length > 255) {
      return 'La descripción no puede tener más de 255 caracteres';
    }

    return null;
  }
}
