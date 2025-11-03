import 'package:intl/intl.dart';
import 'currency_config.dart';

class CurrencyService {
  static CurrencyType _currentCurrency = CurrencyType.clp;
  static CurrencyConfig get _config => CurrencyConfig.get(_currentCurrency);

  // Configuración global
  static void setCurrency(CurrencyType currency) {
    _currentCurrency = currency;
  }

  static CurrencyType get currentCurrency => _currentCurrency;
  static String get currencySymbol => _config.symbol;
  static String get currencyCode => _config.code;

  // Formateo principal
  static String format(double amount, {bool showSymbol = false}) {
    if (amount.isNaN || amount.isInfinite) return '0';
    
    final formatter = NumberFormat(_config.pattern, _config.locale);
    final formattedAmount = formatter.format(amount.abs());
    
    if (showSymbol) {
      return '${_config.symbol}$formattedAmount';
    }
    return formattedAmount;
  }

  // Formateo con símbolo (método principal para la UI)
  static String formatWithSymbol(double amount) {
    return format(amount, showSymbol: true);
  }

  // Parseo de texto a número
  static double parse(String text) {
    if (text.isEmpty) return 0.0;
    
    // Remover símbolo de moneda y espacios
    String cleanText = text
        .replaceAll(_config.symbol, '')
        .replaceAll(' ', '')
        .trim();

    // Para CLP, remover puntos (separadores de miles) y convertir
    if (_currentCurrency == CurrencyType.clp) {
      cleanText = cleanText.replaceAll('.', '');
      return double.tryParse(cleanText) ?? 0.0;
    }

    // Para otras monedas, manejar separadores decimales
    cleanText = cleanText.replaceAll(_config.thousandsSeparator, '');
    if (_config.decimalSeparator != '.') {
      cleanText = cleanText.replaceAll(_config.decimalSeparator, '.');
    }

    return double.tryParse(cleanText) ?? 0.0;
  }

  // Validación de monto
  static bool isValidAmount(String text) {
    final amount = parse(text);
    return amount >= 0 && amount.isFinite;
  }

  // Formateo para input mientras se escribe
  static String formatInput(String input) {
    if (input.isEmpty) return '';
    
    final amount = parse(input);
    if (amount == 0) return '';
    
    return format(amount);
  }

  // Métodos de conveniencia específicos para CLP (compatibilidad)
  static String formatCLP(double amount) => format(amount);
  static String formatCLPWithSymbol(double amount) => formatWithSymbol(amount);
  static double parseAmount(String text) => parse(text);
}
