import 'currency_service.dart';
import 'currency_config.dart';

class CurrencyInit {
  static void initialize() {
    // Configurar CLP como moneda por defecto
    CurrencyService.setCurrency(CurrencyType.clp);
  }

  // Método para cambiar moneda en el futuro
  static void switchToCurrency(CurrencyType currency) {
    CurrencyService.setCurrency(currency);
  }
}
