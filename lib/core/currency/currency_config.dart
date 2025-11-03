enum CurrencyType {
  clp,
  usd,
  eur,
}

class CurrencyConfig {
  final String code;
  final String symbol;
  final String locale;
  final String pattern;
  final int decimalDigits;
  final String thousandsSeparator;
  final String decimalSeparator;

  const CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.pattern,
    required this.decimalDigits,
    required this.thousandsSeparator,
    required this.decimalSeparator,
  });

  static const Map<CurrencyType, CurrencyConfig> _configs = {
    CurrencyType.clp: CurrencyConfig(
      code: 'CLP',
      symbol: '\$',
      locale: 'es_CL',
      pattern: '#,###',
      decimalDigits: 0,
      thousandsSeparator: '.',
      decimalSeparator: ',',
    ),
    CurrencyType.usd: CurrencyConfig(
      code: 'USD',
      symbol: '\$',
      locale: 'en_US',
      pattern: '#,###.##',
      decimalDigits: 2,
      thousandsSeparator: ',',
      decimalSeparator: '.',
    ),
    CurrencyType.eur: CurrencyConfig(
      code: 'EUR',
      symbol: '€',
      locale: 'es_ES',
      pattern: '#,###.##',
      decimalDigits: 2,
      thousandsSeparator: '.',
      decimalSeparator: ',',
    ),
  };

  static CurrencyConfig get(CurrencyType type) {
    return _configs[type] ?? _configs[CurrencyType.clp]!;
  }
}
