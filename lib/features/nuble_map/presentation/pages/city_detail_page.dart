import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import '../../domain/entities/province.dart';
import '../../data/nuble_data.dart';

class CityDetailPage extends StatelessWidget {
  final String cityId;

  const CityDetailPage({
    super.key,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final city = NubleData.getCityById(cityId);

    if (city == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.error ?? 'Error'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(l10n?.noDataFound ?? 'Ciudad no encontrada'),
        ),
      );
    }

    final province = NubleData.getProvinceById(city.provinceId);
    final languageCode = l10n?.locale.languageCode ?? 'es';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/province/${city.provinceId}');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(city.getName(languageCode)),
          backgroundColor: province != null
              ? Color(int.parse(province.color.replaceFirst('#', '0xFF')))
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/province/${city.provinceId}'),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 800;
              final maxWidth = isLargeScreen ? 1200.0 : double.infinity;

              return Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header de la ciudad
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: province != null ? [
                                  Color(int.parse(province.color.replaceFirst('#', '0xFF'))),
                                  Color(int.parse(province.color.replaceFirst('#', '0xFF')))
                                      .withAlpha(204),
                                ] : [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withAlpha(204),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      city.isCapital ? Icons.star : Icons.location_city,
                                      size: isLargeScreen ? 64 : 48,
                                      color: Colors.white,
                                    ),
                                    if (city.isCapital) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          l10n?.capital ?? 'Capital',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isLargeScreen ? 14 : 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: isLargeScreen ? 16 : 12),
                                Text(
                                  city.getName(languageCode),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isLargeScreen ? 12 : 8),
                                Text(
                                  city.getDescription(languageCode),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 18 : 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (province != null) ...[
                                  SizedBox(height: isLargeScreen ? 16 : 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isLargeScreen ? 20 : 16,
                                      vertical: isLargeScreen ? 10 : 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${l10n?.provinces ?? 'Provincia'}: ${province.getName(languageCode)}',
                                      style: TextStyle(
                                        fontSize: isLargeScreen ? 16 : 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: isLargeScreen ? 40 : 32),

                          // Estadísticas
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  Icons.place,
                                  '${city.culturalSites.length}',
                                  l10n?.culturalSites ?? 'Sitios Culturales',
                                  isLargeScreen,
                                ),
                              ),
                              SizedBox(width: isLargeScreen ? 16 : 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  Icons.check_circle,
                                  '${city.culturalSites.where((site) => site.isUnlocked).length}',
                                  l10n?.completedPieces ?? 'Completados',
                                  isLargeScreen,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isLargeScreen ? 40 : 32),

                          // Título de sitios culturales
                          Text(
                            l10n?.culturalSites ?? 'Sitios Culturales',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),

                          SizedBox(height: isLargeScreen ? 24 : 16),

                          // Lista de sitios culturales
                          _buildCulturalSitesList(context, city, isLargeScreen),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: isLargeScreen ? 32 : 28,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: isLargeScreen ? 12 : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: isLargeScreen ? 4 : 2),
            Text(
              label,
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalSitesList(BuildContext context, City city, bool isLargeScreen) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: city.culturalSites.length,
      itemBuilder: (context, index) {
        final site = city.culturalSites[index];

        return Card(
          margin: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            leading: Container(
              padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
              decoration: BoxDecoration(
                color: site.isUnlocked
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getSiteIcon(site.type),
                size: isLargeScreen ? 28 : 24,
                color: site.isUnlocked ? Colors.green : Colors.grey,
              ),
            ),
            title: Text(
              site.getName(languageCode),
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  site.getDescription(languageCode),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: site.isUnlocked
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    site.isUnlocked
                        ? (l10n?.unlocked ?? 'Desbloqueado')
                        : (l10n?.locked ?? 'Bloqueado'),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 12 : 10,
                      color: site.isUnlocked ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: site.isUnlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.lock, color: Colors.grey),
          ),
        );
      },
    );
  }

  IconData _getSiteIcon(String type) {
    switch (type) {
      case 'plaza':
        return Icons.account_balance;
      case 'religious':
        return Icons.church;
      case 'market':
        return Icons.store;
      case 'historical':
        return Icons.museum;
      case 'vineyard':
        return Icons.wine_bar;
      case 'natural':
        return Icons.landscape;
      case 'thermal':
        return Icons.hot_tub;
      default:
        return Icons.place;
    }
  }
}
