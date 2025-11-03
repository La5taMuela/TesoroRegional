// Archivo de compatibilidad - redirige al nuevo sistema
export '../core/currency/currency_service.dart';
export '../core/currency/currency_input_formatter.dart';
export '../core/currency/currency_widgets.dart';
export '../core/currency/currency_config.dart';

// Alias para compatibilidad con código existente
import '../core/currency/currency_input_formatter.dart';
import '../core/currency/currency_service.dart';

class CurrencyFormatter {
  static String formatCLP(double amount) => CurrencyService.format(amount);
  static String formatCLPWithSymbol(double amount) => CurrencyService.formatWithSymbol(amount);
  static double parseAmount(String text) => CurrencyService.parse(text);
  static String formatInput(String input) => CurrencyService.formatInput(input);
}

// Alias para el formateador de input
typedef CLPInputFormatter = CurrencyInputFormatter;
