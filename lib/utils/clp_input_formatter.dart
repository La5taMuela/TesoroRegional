import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CLPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remover todos los caracteres no numéricos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Convertir a número y formatear
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    // Formatear con separadores de miles chilenos (puntos)
    final formatter = NumberFormat('#,###', 'es_CL');
    final newText = formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
