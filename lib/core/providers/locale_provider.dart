import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es', 'CL')) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'es';
    final countryCode = languageCode == 'es' ? 'CL' : 'US';
    state = Locale(languageCode, countryCode);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    state = locale;
  }

  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  Locale getDeviceLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode.startsWith('es')
        ? const Locale('es', 'CL')
        : const Locale('en', 'US');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
