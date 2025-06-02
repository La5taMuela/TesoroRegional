import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/providers/theme_provider.dart';
import 'package:tesoro_regional/core/providers/locale_provider.dart';
import 'package:tesoro_regional/core/services/theme/theme_service.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/qr_generator_page.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/about_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    // Verificación de null safety
    if (l10n == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Text('Cargando traducciones...'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: ListView(
          children: [
            _buildHeader(context, l10n),
            const Divider(),
            _buildDeveloperSection(context, l10n),
            const Divider(),
            _buildAppSection(context, ref, currentTheme, currentLocale, l10n),
            const Divider(),
            _buildAboutSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settings,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsSubtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context, AppLocalizations l10n) {
    return _buildSection(
      context,
      l10n.developerTools,
      [
        _buildSettingItem(
          context,
          l10n.qrGenerator,
          Icons.qr_code,
          l10n.qrGeneratorDesc,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QRGeneratorPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppSection(
      BuildContext context,
      WidgetRef ref,
      ThemeMode currentTheme,
      Locale currentLocale,
      AppLocalizations l10n
      ) {
    return _buildSection(
      context,
      l10n.appSettings,
      [
        _buildLanguageSelector(context, ref, currentLocale, l10n),
        _buildSettingItem(
          context,
          l10n.notifications,
          Icons.notifications,
          l10n.notificationsEnabled,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.notificationsNotAvailable),
              ),
            );
          },
        ),
        _buildThemeSelector(context, ref, currentTheme, l10n),
      ],
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context,
      WidgetRef ref,
      Locale currentLocale,
      AppLocalizations l10n
      ) {
    final localeNotifier = ref.read(localeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.language,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(l10n.language),
        subtitle: Text(localeNotifier.getLocaleName(currentLocale)),
        children: [
          _buildLocaleOption(
            context,
            ref,
            const Locale('es', 'CL'),
            currentLocale.languageCode == 'es',
            l10n,
          ),
          _buildLocaleOption(
            context,
            ref,
            const Locale('en', 'US'),
            currentLocale.languageCode == 'en',
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleOption(
      BuildContext context,
      WidgetRef ref,
      Locale locale,
      bool isSelected,
      AppLocalizations l10n,
      ) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final languageName = locale.languageCode == 'es'
        ? l10n.spanish
        : l10n.english;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(languageName),
      trailing: isSelected
          ? Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
      )
          : null,
      onTap: () {
        localeNotifier.setLocale(locale);

        // Mostrar mensaje después de un breve retraso para que se actualice el idioma
        Future.delayed(const Duration(milliseconds: 100), () {
          final newL10n = AppLocalizations.of(context);
          if (newL10n != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(newL10n.languageChanged),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildThemeSelector(
      BuildContext context,
      WidgetRef ref,
      ThemeMode currentTheme,
      AppLocalizations l10n
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            ThemeService.getThemeIcon(currentTheme),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(l10n.theme),
        subtitle: Text(_getThemeName(currentTheme, l10n)),
        children: [
          _buildThemeOption(
            context,
            ref,
            ThemeMode.light,
            currentTheme == ThemeMode.light,
            l10n,
          ),
          _buildThemeOption(
            context,
            ref,
            ThemeMode.dark,
            currentTheme == ThemeMode.dark,
            l10n,
          ),
          _buildThemeOption(
            context,
            ref,
            ThemeMode.system,
            currentTheme == ThemeMode.system,
            l10n,
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  Widget _buildThemeOption(
      BuildContext context,
      WidgetRef ref,
      ThemeMode themeMode,
      bool isSelected,
      AppLocalizations l10n,
      ) {
    return ListTile(
      leading: Icon(
        ThemeService.getThemeIcon(themeMode),
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(_getThemeName(themeMode, l10n)),
      trailing: isSelected
          ? Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
      )
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(themeMode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.themeChanged} ${_getThemeName(themeMode, l10n)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return _buildSection(
      context,
      l10n.about,
      [
        _buildSettingItem(
          context,
          l10n.aboutApp,
          Icons.info,
          l10n.aboutAppDesc,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
          },
        ),
        _buildSettingItem(
          context,
          l10n.version,
          Icons.new_releases,
          '1.0.0',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tesoro Regional v1.0.0'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingItem(
      BuildContext context,
      String title,
      IconData icon,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
