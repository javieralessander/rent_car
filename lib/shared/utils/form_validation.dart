class FormValidation {
  inputIsEmpty(dynamic value) => (value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
  };

  nameValidator(String? value) => (value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
  };

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value)
        ? null
        : 'El valor ingresado no luce como correo';
  }

  cedulaValidator(String? value) => (value) {
    return (value.isEmpty || !RegExp(r'^\d{3}-\d{7}-\d{1}$').hasMatch(value))
        ? 'Por favor, introduzca una cédula o DNI válida'
        : null;
  };

  passwordValidator(String? value) => (value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    return (value.length >= 6)
        ? null
        : 'La contraseña debe ser de 6 caracteres';
  };
  phoneNumberValidator(String? value) => (value) {
    if (value.length > 1 && value.length < 14) {
      return 'No es un número de teléfono valido';
    }
  };

  descripcionDenunciaValidator(String? value) => (value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
  };

  directionDenunciaValidator(String? value) => (value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
  };

  denunciaCodigoValidator(String? value) => (value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
  };
}
