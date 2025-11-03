import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/core/services/storage/pieces_storage_service.dart';
import '../widgets/interactive_nuble_map.dart' hide Province;
import '../../domain/entities/province.dart';
import '../../data/nuble_data.dart';

class NubleMapPage extends StatefulWidget {
  const NubleMapPage({super.key});

  @override
  State<NubleMapPage> createState() => _NubleMapPageState();
}

class _NubleMapPageState extends State<NubleMapPage> {
  String? _selectedProvinceId;
  List<String> _collectedProvinces = [];
  final PiecesStorageService _storageService = PiecesStorageService();

  @override
  void initState() {
    super.initState();
    _loadCollectedProvinces();
  }

  Future<void> _loadCollectedProvinces() async {
    try {
      final collectedPieces = await _storageService.getCollectedPiecesDetailed();

      final collectedProvinceIds = <String>{};

      for (final piece in collectedPieces) {
        // Get the piece name/title
        final pieceName = piece['name']?.toString() ?? '';
        final normalizedTitle = _normalizeText(pieceName);

        // Check against each province
        for (final province in NubleData.provinces) {
          final normalizedProvinceName = _normalizeText(province.getName('es'));

          if (normalizedTitle.contains(normalizedProvinceName) ||
              normalizedProvinceName.contains(normalizedTitle)) {
            collectedProvinceIds.add(province.id);
            break;
          }

          // Also check cities within the province
          for (final city in province.cities) {
            final normalizedCityName = _normalizeText(city.getName('es'));
            if (normalizedTitle.contains(normalizedCityName) ||
                normalizedCityName.contains(normalizedTitle)) {
              collectedProvinceIds.add(province.id);
              break;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _collectedProvinces = collectedProvinceIds.toList();
        });
      }
    } catch (e) {
      print('Error loading collected provinces: $e');
    }
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  void _onProvinceSelected(Province province) {
    setState(() {
      _selectedProvinceId = province.id;
    });
    _showProvinceDialog(province);
  }

  // Función para obtener el color de la provincia según su estado
  Color _getProvinceColor(String provinceId, bool isCollected) {
    switch (provinceId) {
      case 'diguillin':
        return isCollected
            ? const Color(0xFF1976D2) // Azul intenso
            : const Color(0xFF90CAF9); // Azul claro
      case 'itata':
        return isCollected
            ? const Color(0xFFE65100) // Naranja intenso
            : const Color(0xFFFFCC02); // Naranja claro
      case 'punilla':
        return isCollected
            ? const Color(0xFF7B1FA2) // Púrpura intenso
            : const Color(0xFFBA68C8); // Púrpura claro
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.nubleMap ?? 'Mapa de Ñuble'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n?.selectProvince ?? 'Selecciona una provincia para explorar',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: isLargeScreen ? 500 : 400,
                  child: InteractiveNubleMap(
                    selectedProvinceId: _selectedProvinceId,
                    collectedProvinces: _collectedProvinces,
                    onProvinceSelected: _onProvinceSelected,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildProvinceButtons(context, isLargeScreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceButtons(BuildContext context, bool isLargeScreen) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';

    return Wrap(
      spacing: isLargeScreen ? 20 : 12,
      runSpacing: isLargeScreen ? 16 : 12,
      alignment: WrapAlignment.center,
      children: NubleData.provinces.map((province) {
        final isSelected = _selectedProvinceId == province.id;
        final isCollected = _collectedProvinces.contains(province.id);
        final provinceColor = _getProvinceColor(province.id, isCollected);

        return ElevatedButton(
          onPressed: () => _onProvinceSelected(province),
          style: ElevatedButton.styleFrom(
            backgroundColor: provinceColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 24 : 16,
              vertical: isLargeScreen ? 16 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: provinceColor.withOpacity(0.8),
                width: 2,
              ),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCollected) ...[
                const Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                province.getName(languageCode),
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showProvinceDialog(Province province) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';
    final isCollected = _collectedProvinces.contains(province.id);
    final provinceColor = _getProvinceColor(province.id, isCollected);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (isCollected) ...[
              Icon(Icons.check_circle, color: provinceColor, size: 24),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(province.getName(languageCode))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCollected)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: provinceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: provinceColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: provinceColor),
                    const SizedBox(width: 8),
                    Text(
                      '¡Provincia completada!',
                      style: TextStyle(
                        color: provinceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              'Capital: ${province.capital}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(province.getDescription(languageCode)),
            const SizedBox(height: 12),
            Text(
              '${province.cities.length} ciudades para explorar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/province/${province.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: provinceColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.exploreProvince ?? 'Explorar'),
          ),
        ],
      ),
    );
  }
}
