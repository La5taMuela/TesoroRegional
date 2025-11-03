import 'package:flutter/services.dart';
import 'currency_service.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final bool allowDecimals;
  final double? maxValue;

  CurrencyInputFormatter({
    this.allowDecimals = false,
    this.maxValue,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Extraer solo dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Convertir a número
    final number = double.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    // Verificar límite máximo
    if (maxValue != null && number > maxValue!) {
      return oldValue;
    }

    // Formatear según la moneda actual
    final formattedText = CurrencyService.formatInput(digitsOnly);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
