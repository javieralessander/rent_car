import 'package:flutter/services.dart';

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.trim().replaceAll(RegExp(r'[^\d]'), '');

    // Si el número de teléfono tiene más de 10 dígitos, se trunca a 10 dígitos
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    var buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      var char = text[i];
      switch (i) {
        case 0:
          buffer.write('(');
          buffer.write(char);
          break;
        case 3:
          buffer.write(') ');
          buffer.write(char);
          break;
        case 6:
          buffer.write('-');
          buffer.write(char);
          break;
        default:
          buffer.write(char);
          break;
      }
    }

    var selectionIndex = buffer.length;
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.fromPosition(
        TextPosition(offset: selectionIndex),
      ),
    );
  }
}
