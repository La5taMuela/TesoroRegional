import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/core/providers/locale_provider.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class I18nService {
  final Locale currentLocale;
  final AppLocalizations localizations;

  I18nService({
    required this.currentLocale,
    required this.localizations,
  });

  String translate(String key) {
    return localizations.translate(key);
  }

  String get languageCode => currentLocale.languageCode;
  String get countryCode => currentLocale.countryCode ?? '';
}

final translationsProvider = Provider<Map<String, Map<String, String>>>((ref) {
  return {
    'es': {
      'app_name': 'Tesoro Regional',
      'puzzle_title': 'Rompecabezas',
      'map_title': 'Mapa',
      'missions_title': 'Misiones',
      'stories_title': 'Historias',
      'unlocked': 'Desbloqueado',
      'locked': 'Bloqueado',
      'settings': 'Configuración',
      'settings_subtitle': 'Opciones y herramientas para Tesoro Regional',
      'developer_tools': 'Herramientas de Desarrollo',
      'qr_generator': 'Generador de QR',
      'qr_generator_desc': 'Crea códigos QR para piezas del puzzle',
      'app_settings': 'Configuración de la App',
      'language': 'Idioma',
      'notifications': 'Notificaciones',
      'notifications_enabled': 'Activadas',
      'theme': 'Tema',
      'light_theme': 'Claro',
      'dark_theme': 'Oscuro',
      'system_theme': 'Sistema',
      'about': 'Acerca de',
      'about_app': 'Acerca de Tesoro Regional',
      'about_app_desc': 'Información sobre la aplicación',
      'version': 'Versión',
      'language_changed': 'Idioma cambiado a Español',
      'theme_changed': 'Tema cambiado a',
      'back': 'Atrás',
      'select_language': 'Seleccionar idioma',
      'spanish': 'Español',
      'english': 'Inglés',
      'language_not_available': 'Cambio de idioma no disponible en esta versión',
      'notifications_not_available': 'Configuración de notificaciones no disponible en esta versión',
    },
    'en': {
      'app_name': 'Living Memory',
      'puzzle_title': 'Puzzle',
      'map_title': 'Map',
      'missions_title': 'Missions',
      'stories_title': 'Stories',
      'unlocked': 'Unlocked',
      'locked': 'Locked',
      'settings': 'Settings',
      'settings_subtitle': 'Options and tools for Regional Treasure',
      'developer_tools': 'Developer Tools',
      'qr_generator': 'QR Generator',
      'qr_generator_desc': 'Create QR codes for puzzle pieces',
      'app_settings': 'App Settings',
      'language': 'Language',
      'notifications': 'Notifications',
      'notifications_enabled': 'Enabled',
      'theme': 'Theme',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'system_theme': 'System',
      'about': 'About',
      'about_app': 'About Regional Treasure',
      'about_app_desc': 'Information about the application',
      'version': 'Version',
      'language_changed': 'Language changed to English',
      'theme_changed': 'Theme changed to',
      'back': 'Back',
      'select_language': 'Select language',
      'spanish': 'Spanish',
      'english': 'English',
      'language_not_available': 'Language change not available in this version',
      'notifications_not_available': 'Notification settings not available in this version',
    },
  };
});

final i18nServiceProvider = Provider<I18nService?>((ref) {
  ref.watch(localeProvider);
  // This will be properly initialized in the widget tree
  return null;
});

// Extension for easy access to translations
extension BuildContextExtensions on BuildContext {
  AppLocalizations? get l10n => AppLocalizations.of(this);
  String get languageCode => Localizations.localeOf(this).languageCode;
}
