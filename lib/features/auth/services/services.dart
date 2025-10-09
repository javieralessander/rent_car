import 'package:flutter/material.dart';

import '../../../core/models/user.dart';

class RegisterService extends ChangeNotifier {
  User user = User();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _obscureText = true;
  bool get obscureText => _obscureText;
  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  // Método para validar el formulario
  bool isValidForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  // Simulación de registro (debes implementar tu lógica real aquí)
  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    isLoading = true;
    try {
      // Aquí iría tu lógica real de registro (ejemplo: Firebase Auth)
      await Future.delayed(const Duration(seconds: 2));
      // Si el registro es exitoso
      isLoading = false;
      return true;
    } catch (e) {
      isLoading = false;
      return false;
    }
  }
}

class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);
}
