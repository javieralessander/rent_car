import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Tipos de tarjetas de crédito soportadas
enum CreditCardType {
  unknown,
  visa,
  mastercard,
  amex,
}

/// Utilidad para detectar tipo de tarjeta de crédito
class CreditCardUtils {
  /// Detecta el tipo de tarjeta basado en el número
  static CreditCardType detectCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanNumber.isEmpty) return CreditCardType.unknown;

    // American Express: comienza con 34 o 37
    if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      return CreditCardType.amex;
    }

    // Mastercard: comienza con 5 o 2221-2720
    if (RegExp(r'^5[1-5]').hasMatch(cleanNumber) ||
        RegExp(r'^2(22[1-9]|2[3-9]|[3-6]|7[01]|720)').hasMatch(cleanNumber)) {
      return CreditCardType.mastercard;
    }

    // Visa: comienza con 4
    if (RegExp(r'^4').hasMatch(cleanNumber)) {
      return CreditCardType.visa;
    }

    return CreditCardType.unknown;
  }

  /// Obtiene la longitud máxima para cada tipo de tarjeta
  static int getMaxLength(CreditCardType type) {
    switch (type) {
      case CreditCardType.amex:
        return 15;
      case CreditCardType.visa:
      case CreditCardType.mastercard:
        return 16;
      case CreditCardType.unknown:
        return 19; // Máximo general
    }
  }

  /// Obtiene el patrón de espaciado para cada tipo de tarjeta
  static String formatCardNumber(String cardNumber, CreditCardType type) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanNumber.isEmpty) return '';

    switch (type) {
      case CreditCardType.amex:
        // XXXX XXXXXX XXXXX (4-6-5)
        String formatted = '';
        for (int i = 0; i < cleanNumber.length; i++) {
          if (i == 4 || i == 10) formatted += ' ';
          formatted += cleanNumber[i];
        }
        return formatted;

      case CreditCardType.visa:
      case CreditCardType.mastercard:
      default:
        // XXXX XXXX XXXX XXXX (4-4-4-4)
        String formatted = '';
        for (int i = 0; i < cleanNumber.length; i++) {
          if (i > 0 && i % 4 == 0) formatted += ' ';
          formatted += cleanNumber[i];
        }
        return formatted;
    }
  }

  /// Obtiene el ícono para cada tipo de tarjeta usando imágenes reales
  static Widget getCardIcon(CreditCardType type, {double width = 32, double height = 20}) {
    switch (type) {
      case CreditCardType.visa:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/visa.png',
              width: width,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon('VISA', const Color(0xFF1A1F71), width, height);
              },
            ),
          ),
        );
      case CreditCardType.mastercard:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/mastercard.png',
              width: width,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon('MC', const Color(0xFFEB001B), width, height);
              },
            ),
          ),
        );
      case CreditCardType.amex:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/amex.png',
              width: width,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon('AMEX', const Color(0xFF006FCF), width, height);
              },
            ),
          ),
        );
      case CreditCardType.unknown:
      default:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!, width: 1),
          ),
          child: const Icon(
            Icons.credit_card,
            size: 12,
            color: Colors.grey,
          ),
        );
    }
  }

  /// Widget de respaldo en caso de que la imagen no se cargue
  static Widget _buildFallbackIcon(String text, Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.25, // Tamaño dinámico basado en el ancho
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Conjunto de validaciones reutilizables para formularios de la aplicación.
class InputValidators {
  static String? requiredText(
    String? value, {
    String fieldName = 'Campo',
    int? minLength,
    int? maxLength,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName es requerido';
    }
    if (minLength != null && trimmed.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName debe tener máximo $maxLength caracteres';
    }
    return null;
  }

  static String? digitsOnly(
    String? value, {
    required String fieldName,
    int? exactLength,
    int? minLength,
    int? maxLength,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName es requerido';
    }
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return '$fieldName solo debe contener dígitos';
    }
    if (exactLength != null && trimmed.length != exactLength) {
      return '$fieldName debe tener exactamente $exactLength dígitos';
    }
    if (minLength != null && trimmed.length < minLength) {
      return '$fieldName debe tener al menos $minLength dígitos';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName debe tener máximo $maxLength dígitos';
    }
    return null;
  }

  static String? alphaNumeric(
    String? value, {
    required String fieldName,
    bool allowSpaces = false,
    int? minLength,
    int? maxLength,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName es requerido';
    }
    final pattern = allowSpaces ? r'^[A-Za-z0-9\s-]+$' : r'^[A-Za-z0-9-]+$';
    if (!RegExp(pattern).hasMatch(trimmed)) {
      return '$fieldName solo debe contener letras y números';
    }
    if (minLength != null && trimmed.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName debe tener máximo $maxLength caracteres';
    }
    return null;
  }

  static String? positiveNumber(
    num? value, {
    String fieldName = 'Valor',
    bool allowZero = false,
  }) {
    if (value == null) {
      return '$fieldName es requerido';
    }
    if (allowZero) {
      if (value < 0) return '$fieldName debe ser mayor o igual a 0';
    } else {
      if (value <= 0) return '$fieldName debe ser mayor a 0';
    }
    return null;
  }

  static String? percentage(num? value, {String fieldName = 'Porcentaje'}) {
    if (value == null) return '$fieldName es requerido';
    if (value < 0 || value > 100) {
      return '$fieldName debe estar entre 0 y 100';
    }
    return null;
  }

  static String? requiredDecimal(
    String? value, {
    String fieldName = 'Valor',
    double? minValue,
    double? maxValue,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName es requerido';
    }

    final numValue = double.tryParse(trimmed);
    if (numValue == null) {
      return '$fieldName debe ser un número válido';
    }

    if (minValue != null && numValue < minValue) {
      return '$fieldName debe ser mayor o igual a $minValue';
    }

    if (maxValue != null && numValue > maxValue) {
      return '$fieldName debe ser menor o igual a $maxValue';
    }

    return null;
  }

  static String? dateNotInFuture(
    DateTime? value, {
    String fieldName = 'Fecha',
  }) {
    if (value == null) return '$fieldName es requerida';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(value.year, value.month, value.day);

    if (selectedDate.isAfter(today)) {
      return '$fieldName no puede ser futura';
    }

    return null;
  }

  static String? dateRange(
    DateTime? startDate,
    DateTime? endDate, {
    String startFieldName = 'Fecha inicio',
    String endFieldName = 'Fecha fin',
  }) {
    if (startDate == null) return '$startFieldName es requerida';
    if (endDate == null) return '$endFieldName es requerida';

    if (endDate.isBefore(startDate)) {
      return '$endFieldName debe ser posterior a $startFieldName';
    }

    return null;
  }

  static String? dateAfterOrEqual(
    DateTime? targetDate,
    DateTime? referenceDate, {
    String targetFieldName = 'Fecha',
    String referenceFieldName = 'fecha de referencia',
  }) {
    if (targetDate == null || referenceDate == null) return null;

    if (targetDate.isBefore(referenceDate)) {
      return '$targetFieldName no puede ser anterior a la $referenceFieldName';
    }

    return null;
  }

  static String? requiredNumber(
    String? value, {
    String fieldName = 'Campo',
    double? minValue,
    double? maxValue,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName es requerido';
    }

    final numValue = double.tryParse(trimmed);
    if (numValue == null) {
      return '$fieldName debe ser un número válido';
    }

    if (minValue != null && numValue < minValue) {
      return '$fieldName debe ser mayor o igual a $minValue';
    }

    if (maxValue != null && numValue > maxValue) {
      return '$fieldName debe ser menor o igual a $maxValue';
    }

    return null;
  }

  static String? email(
    String? value, {
    String fieldName = 'Correo electrónico',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldName es requerido';
    final emailRegex = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return '$fieldName no es válido';
    }
    return null;
  }

  static String? cedulaDominicana(
    String? value, {
    String fieldName = 'Cédula',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldName es requerida';

    // Remover guiones para validar
    final digitsOnly = trimmed.replaceAll('-', '');

    if (digitsOnly.length != 11) {
      return '$fieldName debe tener 11 dígitos';
    }

    if (!RegExp(r'^\d{11}$').hasMatch(digitsOnly)) {
      return '$fieldName solo debe contener números';
    }

    // Aplicar algoritmo de validación dominicano
    if (!_validaCedulaDominicana(digitsOnly)) {
      return 'Cédula ingresada no es válida, por favor verifique los dígitos';
    }

    return null;
  }

  static String? rncDominicano(
    String? value, {
    String fieldName = 'RNC',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldName es requerido';

    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length != 9) {
      return '$fieldName debe tener 9 dígitos';
    }

    if (!RegExp(r'^\d{9}$').hasMatch(digitsOnly)) {
      return '$fieldName solo debe contener números';
    }

    // Aplicar algoritmo de validación RNC dominicano
    if (!_validarRNCDominicano(digitsOnly)) {
      return 'RNC ingresado no es válido, por favor verifique los dígitos';
    }

    return null;
  }

  /// Algoritmo de validación de cédula dominicana
  static bool _validaCedulaDominicana(String pCedula) {
    int vnTotal = 0;
    String vcCedula = pCedula.replaceAll('-', '').trim();
    int pLongCed = vcCedula.length;
    List<int> digitoMult = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1];

    if (pLongCed != 11) {
      return false;
    }

    // Verificar que todos sean dígitos
    if (!RegExp(r'^\d{11}$').hasMatch(vcCedula)) {
      return false;
    }

    for (int vDig = 1; vDig <= pLongCed; vDig++) {
      int vCalculo = int.parse(vcCedula.substring(vDig - 1, vDig)) * digitoMult[vDig - 1];
      if (vCalculo < 10) {
        vnTotal += vCalculo;
      } else {
        String vCalculoStr = vCalculo.toString();
        vnTotal += int.parse(vCalculoStr.substring(0, 1)) + int.parse(vCalculoStr.substring(1, 2));
      }
    }

    return vnTotal % 10 == 0;
  }

  /// Algoritmo de validación de RNC dominicano
  static bool _validarRNCDominicano(String rnc) {
    rnc = rnc.trim();
    List<int> peso = [7, 9, 8, 6, 5, 4, 3, 2];
    int suma = 0;

    if (rnc.length != 9) {
      return false;
    }

    // Verificar que todos sean dígitos
    if (!RegExp(r'^\d{9}$').hasMatch(rnc)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      suma += int.parse(rnc[i]) * peso[i];
    }

    int division = suma ~/ 11;
    int resto = suma - (division * 11);
    int digito = 0;

    if (resto == 0) {
      digito = 2;
    } else if (resto == 1) {
      digito = 1;
    } else {
      digito = 11 - resto;
    }

    return digito == int.parse(rnc[8]);
  }

  static String? creditCard(
    String? value, {
    String fieldName = 'Número de tarjeta',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldName es requerido';

    final cleanNumber = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    final cardType = CreditCardUtils.detectCardType(cleanNumber);

    if (cardType == CreditCardType.unknown) {
      return '$fieldName no es válido';
    }

    final expectedLength = CreditCardUtils.getMaxLength(cardType);
    if (cleanNumber.length != expectedLength) {
      String cardTypeName = '';
      switch (cardType) {
        case CreditCardType.amex:
          cardTypeName = 'American Express';
          break;
        case CreditCardType.visa:
          cardTypeName = 'Visa';
          break;
        case CreditCardType.mastercard:
          cardTypeName = 'Mastercard';
          break;
        case CreditCardType.unknown:
          break;
      }
      return '$cardTypeName debe tener $expectedLength dígitos';
    }

    return null;
  }

  static String? phone(
    String? value, {
    String fieldName = 'Teléfono',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldName es requerido';

    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length != 10) {
      return '$fieldName debe tener 10 dígitos';
    }

    // Validar que comience con códigos válidos dominicanos
    final validPrefixes = ['809', '829', '849'];
    final prefix = digitsOnly.substring(0, 3);

    if (!validPrefixes.contains(prefix)) {
      return '$fieldName debe comenzar con 809, 829 o 849';
    }

    return null;
  }
}

/// Utilidades de formateo reutilizables.
class InputFormatters {
  static TextInputFormatter uppercase() => UpperCaseTextFormatter();

  static List<TextInputFormatter> digitsOnly({int? maxLength}) {
    return [
      FilteringTextInputFormatter.digitsOnly,
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> numeric({int? maxLength}) {
    return [
      FilteringTextInputFormatter.digitsOnly,
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> cedula() => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        CedulaFormater(),
      ];

  static List<TextInputFormatter> rnc() => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
        RncFormatter(),
      ];

  static List<TextInputFormatter> cardNumber() => [
        FilteringTextInputFormatter.digitsOnly,
        CreditCardFormatter(),
      ];

  static List<TextInputFormatter> plate({int maxLength = 10}) {
    return [
      UpperCaseTextFormatter(),
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> alphaNumeric({
    int? maxLength,
    bool allowSpaces = false,
  }) {
    final pattern =
        allowSpaces ? RegExp(r'[A-Za-z0-9\s-]') : RegExp(r'[A-Za-z0-9-]');
    return [
      UpperCaseTextFormatter(),
      FilteringTextInputFormatter.allow(pattern),
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> names({int? maxLength}) {
    return [
      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÁÉÍÓÚáéíóúÑñüÜ\s]")),
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  /// Formatter para teléfonos dominicanos: (XXX) XXX-XXXX
  static List<TextInputFormatter> phone() => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
        PhoneFormatter(),
      ];

  /// Formatea un número como moneda dominicana (RD$): RD$ 1,234.56
  static String formatCurrency(double amount, {bool includeCurrencySymbol = true}) {
    final formatter = NumberFormat('#,##0.00', 'es_DO');
    final formattedAmount = formatter.format(amount);
    return includeCurrencySymbol ? 'RD\$ $formattedAmount' : formattedAmount;
  }

  /// Formatea un número con separadores de miles dominicanos: 1,234.56
  static String formatNumber(double number, {int decimalPlaces = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', 'es_DO');
    return formatter.format(number);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

/// Formatter para cédula dominicana: XXX-XXXXXXX-X
class CedulaFormater extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    if (digitsOnly.length >= 1) {
      formatted += digitsOnly.substring(0, digitsOnly.length >= 3 ? 3 : digitsOnly.length);
    }
    if (digitsOnly.length >= 4) {
      formatted += '-${digitsOnly.substring(3, digitsOnly.length >= 10 ? 10 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 11) {
      formatted += '-${digitsOnly.substring(10, 11)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter para RNC dominicano: XXXXXXXXX (9 dígitos)
class RncFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > 9) {
      return oldValue;
    }

    return newValue.copyWith(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

/// Formatter para tarjetas de crédito con formato dinámico
class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cardType = CreditCardUtils.detectCardType(digitsOnly);
    final maxLength = CreditCardUtils.getMaxLength(cardType);

    if (digitsOnly.length > maxLength) {
      return oldValue;
    }

    final formatted = CreditCardUtils.formatCardNumber(digitsOnly, cardType);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter para teléfonos dominicanos: (XXX) XXX-XXXX
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (digitsOnly.length > 10) {
      return oldValue;
    }

    String formatted = '';
    if (digitsOnly.length >= 1) {
      formatted += '(${digitsOnly.substring(0, digitsOnly.length >= 3 ? 3 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 4) {
      formatted += ') ${digitsOnly.substring(3, digitsOnly.length >= 6 ? 6 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 7) {
      formatted += '-${digitsOnly.substring(6, digitsOnly.length)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
