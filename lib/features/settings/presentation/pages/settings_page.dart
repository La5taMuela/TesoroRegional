import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/providers/locale_provider.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';
import 'package:tesoro_regional/features/settings/presentation/pages/about_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final PiecesStorageService _piecesService = PiecesStorageService();
  Map<String, dynamic> _userStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await _piecesService.getPiecesStats();
      final collectedPieces = await _piecesService.getCollectedPiecesDetailed();

      setState(() {
        _userStats = {
          ...stats,
          'collectedPieces': collectedPieces,
          'lastActivity': collectedPieces.isNotEmpty
              ? collectedPieces.last['collectedAt'] ?? ''
              : '',
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;
    final isSmallScreen = screenWidth <= 600;

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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(l10n.settings),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 1200 : (isMediumScreen ? 800 : double.infinity),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Layout responsivo para las tarjetas principales
                  if (isLargeScreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildAppSettingsCard(context, ref, currentLocale, l10n, isLargeScreen, isMediumScreen),
                              const SizedBox(height: 20),
                              _buildDataManagementCard(context, l10n, isLargeScreen, isMediumScreen),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _buildSupportCard(context, l10n, isLargeScreen, isMediumScreen),
                              const SizedBox(height: 20),
                              if (kIsWeb) _buildWebDownloadCard(context, isLargeScreen, isMediumScreen),
                              if (kIsWeb) const SizedBox(height: 20),
                              _buildAboutCard(context, l10n, isLargeScreen, isMediumScreen),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildAppSettingsCard(context, ref, currentLocale, l10n, isLargeScreen, isMediumScreen),
                        const SizedBox(height: 20),
                        _buildDataManagementCard(context, l10n, isLargeScreen, isMediumScreen),
                        const SizedBox(height: 20),
                        _buildSupportCard(context, l10n, isLargeScreen, isMediumScreen),
                        if (kIsWeb) ...[
                          const SizedBox(height: 20),
                          _buildWebDownloadCard(context, isLargeScreen, isMediumScreen),
                        ],
                        const SizedBox(height: 20),
                        _buildAboutCard(context, l10n, isLargeScreen, isMediumScreen),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isLargeScreen) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: isLargeScreen ? 28 : 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLargeScreen ? 14 : 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      bool isLargeScreen,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isLargeScreen ? 32 : 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard(
      BuildContext context,
      WidgetRef ref,
      Locale currentLocale,
      AppLocalizations l10n,
      bool isLargeScreen,
      bool isMediumScreen,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                  size: isLargeScreen ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.settings,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLanguageSelector(context, ref, currentLocale, l10n, isLargeScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard(BuildContext context, AppLocalizations l10n, bool isLargeScreen, bool isMediumScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).primaryColor,
                  size: isLargeScreen ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Gestión de Datos',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              context,
              'Limpiar Datos',
              Icons.delete_sweep,
              'Reiniciar todo el progreso',
              onTap: () => _showClearDataDialog(context),
              isLargeScreen: isLargeScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, AppLocalizations l10n, bool isLargeScreen, bool isMediumScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help,
                  color: Theme.of(context).primaryColor,
                  size: isLargeScreen ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Soporte y Ayuda',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              context,
              'Calificar App',
              Icons.star,
              'Danos tu opinión en una pequeña encuesta',
              onTap: () => _rateApp(context),
              isLargeScreen: isLargeScreen,
            ),
            _buildSettingItem(
              context,
              'Tutorial',
              Icons.school,
              'Aprende a usar todas las funciones',
              onTap: () => _showTutorial(context),
              isLargeScreen: isLargeScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebDownloadCard(BuildContext context, bool isLargeScreen, bool isMediumScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.green.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.android,
                    color: Colors.blue,
                    size: isLargeScreen ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descargar App Móvil',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Experiencia completa en Android',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Obtén la experiencia completa con funciones offline:',
              style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow('GPS y ubicación precisa', isLargeScreen),
            _buildFeatureRow('Cámara integrada para QR', isLargeScreen),
            _buildFeatureRow('Notificaciones de proximidad', isLargeScreen),
            _buildFeatureRow('Funciona sin internet', isLargeScreen),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadApp(),
                icon: const Icon(Icons.download),
                label: const Text('Descargar APK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: isLargeScreen ? 18 : 16),
          const SizedBox(width: 8),
          Text(feature, style: TextStyle(fontSize: isLargeScreen ? 15 : 13)),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l10n, bool isLargeScreen, bool isMediumScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                  size: isLargeScreen ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.about,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              context,
              l10n.aboutApp,
              Icons.info_outline,
              l10n.aboutAppDesc,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
              isLargeScreen: isLargeScreen,
            ),
            _buildSettingItem(
              context,
              l10n.version,
              Icons.new_releases,
              '1.0.0 - Versión inicial',
              onTap: () => _showVersionInfo(context),
              isLargeScreen: isLargeScreen,
            ),
            _buildSettingItem(
              context,
              'Términos y Condiciones',
              Icons.description,
              'Políticas de uso y privacidad',
              onTap: () => _showTerms(context),
              isLargeScreen: isLargeScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context,
      WidgetRef ref,
      Locale currentLocale,
      AppLocalizations l10n,
      bool isLargeScreen,
      ) {
    final localeNotifier = ref.read(localeProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.language,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(l10n.language, style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
        subtitle: Text(localeNotifier.getLocaleName(currentLocale), style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
        children: [
          _buildLocaleOption(context, ref, const Locale('es', 'CL'),
              currentLocale.languageCode == 'es', l10n, isLargeScreen),
          _buildLocaleOption(context, ref, const Locale('en', 'US'),
              currentLocale.languageCode == 'en', l10n, isLargeScreen),
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
      bool isLargeScreen,
      ) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final languageName = locale.languageCode == 'es' ? l10n.spanish : l10n.english;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
      title: Text(languageName, style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        localeNotifier.setLocale(locale);
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

  Widget _buildSettingItem(
      BuildContext context,
      String title,
      IconData icon,
      String subtitle, {
        VoidCallback? onTap,
        bool isLargeScreen = false,
      }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }

  // Action methods
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Text('Esta función estará disponible en una futura actualización.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _exportProgress(BuildContext context) async {
    try {
      final pieces = await _piecesService.getCollectedPiecesDetailed();
      final stats = await _piecesService.getPiecesStats();

      await Share.share(
        'Mi progreso en Tesoro Regional:\n'
            'Piezas colectadas: ${stats['total']}\n'
            'Progreso: ${stats['percentage']}%\n'
            'Sitios visitados: ${stats['mapPieces']}\n'
            'Provincias QR: ${stats['qrPieces']}\n\n'
            'Datos exportados: ${DateTime.now().toString()}',
        subject: 'Mi Progreso - Tesoro Regional',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al exportar progreso')),
      );
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Limpiar Datos'),
        content: const Text(
            'Esta acción eliminará todo tu progreso de forma permanente. '
                '¿Estás seguro de que quieres continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _piecesService.clearAllPieces();
              await _loadUserStats();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos eliminados correctamente')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _syncData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Sincronizando...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    await _loadUserStats();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos sincronizados correctamente')),
    );
  }

  void _shareApp(BuildContext context) {
    Share.share(
      '¡Descubre los tesoros culturales de Ñuble! 🏛️\n\n'
          'Tesoro Regional es una app que te permite explorar la región de Ñuble '
          'a través de códigos QR y un mapa interactivo.\n\n'
          '📱 Descarga la app y únete a la aventura cultural!',
      subject: 'Tesoro Regional - Explora Ñuble',
    );
  }

  // MÉTODO MEJORADO: _rateApp con mejor manejo de errores y fallbacks
  void _rateApp(BuildContext context) async {
    const formUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=oeChOLG26UKzqVl2JmcLF3DqdBZv-mxKrr-mlIpvL3BURE5VTU5JQ1U1UTlOOEQ4VlMxMlJWTVZDNy4u';

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Abriendo formulario...'),
          ],
        ),
      ),
    );

    try {
      final uri = Uri.parse(formUrl);

      // Verificar si se puede abrir la URL
      final canLaunch = await canLaunchUrl(uri);

      // Cerrar el diálogo de carga
      if (mounted) Navigator.of(context).pop();

      await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView, // Esto abrirá la URL en una vista web dentro de la app
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } catch (e) {
      print('Error al abrir formulario: $e');

      if (mounted) {
        // Mostrar diálogo con opciones alternativas
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('No se pudo abrir el formulario'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Puedes calificar la app de las siguientes maneras:'),
                const SizedBox(height: 16),
                const Text('1. Copiar enlace y abrir manualmente'),
                const SizedBox(height: 8),
                const Text('2. Compartir enlace por otra app'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SelectableText(
                    formUrl,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _copyToClipboard(context, formUrl);
                },
                child: const Text('Copiar Enlace'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareFormUrl(formUrl);
                },
                child: const Text('Compartir'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Método para copiar al portapapeles
  void _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Enlace copiado al portapapeles'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al copiar enlace'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para compartir la URL del formulario
  void _shareFormUrl(String url) {
    Share.share(
      'Califica la app Tesoro Regional:\n\n$url',
      subject: 'Formulario de Evaluación - Tesoro Regional',
    );
  }

  void _showTutorial(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📚 Tutorial'),
        content: SizedBox(
          width: isLargeScreen ? 500 : double.maxFinite,
          child: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🗺️ Mapa Interactivo:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Explora sitios culturales de Ñuble\n• Acércate a los puntos para desbloquearlos\n'),

                Text('📱 Escáner QR:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Escanea códigos QR de las provincias\n• Colecciona piezas culturales\n'),

                Text('🏆 Colección:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Ve tu progreso y piezas colectadas\n• Completa el 100% para ser un experto\n'),

                Text('⚙️ Configuración:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Cambia el idioma'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('¡Entendido!'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Versión'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión: 1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Novedades:'),
            Text('• Mapa interactivo de Ñuble'),
            Text('• Escáner QR para provincias'),
            Text('• Sistema de colección de piezas'),
            Text('• Soporte multiidioma'),
            Text('• Interfaz moderna y intuitiva'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SizedBox(
          width: isLargeScreen ? 600 : double.maxFinite,
          child: const SingleChildScrollView(
            child: Text(
              'Términos de Uso - Tesoro Regional\n\n'
                  '1. La aplicación es de uso educativo y cultural.\n'
                  '2. Los datos de ubicación se usan solo para funciones del mapa.\n'
                  '3. No recopilamos información personal identificable.\n'
                  '4. El contenido cultural es con fines informativos.\n'
                  '5. Respeta los sitios culturales al visitarlos.\n\n'
                  'Política de Privacidad:\n'
                  '• Los datos se almacenan localmente en tu dispositivo\n'
                  '• No compartimos información con terceros\n'
                  '• Puedes eliminar tus datos en cualquier momento',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadApp() async {
    const url = 'https://download937.mediafire.com/o5eja07uqszgPgqandohJpLwO9NREYMaJLx5UH9zHmMj_arjBDTQyB4fCmG496ekhYWw1X5kE5oGs0vO7FEOybqDVaa9ePGEh8NoSnVFJ2gw1pBpaxhxom02ZXVmijxR1LeC1SXGxpfSDmRGXrnjxFG1jiHUm97l3f1UZ7Oh2V_9Vus/tcyukmw8g45fxtr/Tesoro+Regional.apk';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el enlace';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al abrir enlace de descarga')),
      );
    }
  }
}
