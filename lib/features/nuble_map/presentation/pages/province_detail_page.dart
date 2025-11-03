import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import '../../domain/entities/province.dart';
import '../../data/nuble_data.dart';
import '../widgets/puzzle_piece_city_card.dart';

class ProvinceDetailPage extends StatelessWidget {
  final String provinceId;

  const ProvinceDetailPage({
    super.key,
    required this.provinceId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final province = NubleData.getProvinceById(provinceId);

    if (province == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.error ?? 'Error'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(l10n?.noDataFound ?? 'Provincia no encontrada'),
        ),
      );
    }

    final languageCode = l10n?.locale.languageCode ?? 'es';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/nuble-map');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(province.getName(languageCode)),
          backgroundColor: Color(int.parse(province.color.replaceFirst('#', '0xFF'))),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/nuble-map'),
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
                          // Header de la provincia
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(int.parse(province.color.replaceFirst('#', '0xFF'))),
                                  Color(int.parse(province.color.replaceFirst('#', '0xFF')))
                                      .withAlpha(204),
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
                                Icon(
                                  Icons.location_city,
                                  size: isLargeScreen ? 64 : 48,
                                  color: Colors.white,
                                ),
                                SizedBox(height: isLargeScreen ? 16 : 12),
                                Text(
                                  province.getName(languageCode),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isLargeScreen ? 12 : 8),
                                Text(
                                  province.getDescription(languageCode),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 18 : 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                    '${l10n?.capital ?? 'Capital'}: ${province.capital}',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 16 : 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
                                  Icons.location_city,
                                  '${province.cities.length}',
                                  l10n?.cities ?? 'Ciudades',
                                  isLargeScreen,
                                ),
                              ),
                              SizedBox(width: isLargeScreen ? 16 : 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  Icons.place,
                                  '${province.cities.expand((city) => city.culturalSites).length}',
                                  l10n?.culturalSites ?? 'Sitios Culturales',
                                  isLargeScreen,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isLargeScreen ? 40 : 32),

                          // Título de ciudades
                          Text(
                            l10n?.discoverCities ?? 'Descubrir Ciudades',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),

                          SizedBox(height: isLargeScreen ? 24 : 16),

                          // Grid de ciudades como piezas de puzzle
                          _buildCitiesGrid(context, province, isLargeScreen),
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

  Widget _buildCitiesGrid(BuildContext context, Province province, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth > 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isLargeScreen ? 24 : 16,
            mainAxisSpacing: isLargeScreen ? 24 : 16,
            childAspectRatio: isLargeScreen ? 1.1 : 1.0,
          ),
          itemCount: province.cities.length,
          itemBuilder: (context, index) {
            final city = province.cities[index];
            return PuzzlePieceCityCard(
              city: city,
              provinceColor: province.color,
              onTap: () => context.go('/city/${city.id}'),
            );
          },
        );
      },
    );
  }
}
