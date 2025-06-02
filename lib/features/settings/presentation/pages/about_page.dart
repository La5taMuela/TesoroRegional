import 'package:flutter/material.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'Unknown';

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            _buildSection(
              l10n.appName,
              'Aplicación para descubrir el patrimonio cultural de la región de Ñuble',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Acerca de Tesoro Regional',
              'Tesoro Regional es una aplicación interactiva que te permite explorar y descubrir el rico patrimonio cultural de la región de Ñuble a través de códigos QR, minijuegos y mapas interactivos.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Características',
              '• Escaneo de códigos QR para descubrir piezas culturales\n• Minijuegos educativos\n• Mapa interactivo de sitios culturales\n• Sistema de progreso y logros',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Desarrollado por',
              'Equipo de desarrollo Universidad del Bío-Bío',
            ),
            const SizedBox(height: 16),
            _buildSection(
              '${l10n.version}',
              'Versión: $_version',
            ),
            const SizedBox(height: 24),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.extension,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre la cultura de Ñuble',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contacto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              context,
              Icons.email,
              'Email',
              'contacto@tesororegional.cl',
            ),
            const Divider(),
            _buildContactItem(
              context,
              Icons.language,
              'Sitio web',
              'www.tesororegional.cl',
            ),
            const Divider(),
            _buildContactItem(
              context,
              Icons.location_on,
              'Dirección',
              'Universidad del Bío-Bío, Chillán',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
