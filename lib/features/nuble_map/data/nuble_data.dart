import '../domain/entities/province.dart';

class NubleData {
  static const List<Province> provinces = [
    Province(
      id: 'diguillin',
      name: {
        'es': 'Diguillín',
        'en': 'Diguillín',
      },
      description: {
        'es': 'Provincia central de Ñuble, conocida por su rica historia y tradiciones.',
        'en': 'Central province of Ñuble, known for its rich history and traditions.',
      },
      capital: 'Chillán',
      color: '#4CAF50',
      cities: [
        City(
          id: 'chillan',
          provinceId: 'diguillin',
          name: {
            'es': 'Chillán',
            'en': 'Chillán',
          },
          description: {
            'es': 'Capital provincial, famosa por su mercado y tradiciones.',
            'en': 'Provincial capital, famous for its market and traditions.',
          },
          isCapital: true,
          culturalSites: [
            CulturalSite(
              id: 'plaza_chillan',
              name: {
                'es': 'Plaza de Armas de Chillán',
                'en': 'Chillán Main Square',
              },
              description: {
                'es': 'Centro histórico de la ciudad.',
                'en': 'Historic center of the city.',
              },
              type: 'plaza',
              isUnlocked: true,
            ),
            CulturalSite(
              id: 'catedral_chillan',
              name: {
                'es': 'Catedral de Chillán',
                'en': 'Chillán Cathedral',
              },
              description: {
                'es': 'Importante templo religioso.',
                'en': 'Important religious temple.',
              },
              type: 'religious',
              isUnlocked: false,
            ),
          ],
        ),
        City(
          id: 'bulnes',
          provinceId: 'diguillin',
          name: {
            'es': 'Bulnes',
            'en': 'Bulnes',
          },
          description: {
            'es': 'Ciudad histórica con importante patrimonio.',
            'en': 'Historic city with important heritage.',
          },
          isCapital: false,
          culturalSites: [
            CulturalSite(
              id: 'museo_bulnes',
              name: {
                'es': 'Museo de Bulnes',
                'en': 'Bulnes Museum',
              },
              description: {
                'es': 'Museo local con historia regional.',
                'en': 'Local museum with regional history.',
              },
              type: 'historical',
              isUnlocked: false,
            ),
          ],
        ),
      ],
    ),
    Province(
      id: 'itata',
      name: {
        'es': 'Itata',
        'en': 'Itata',
      },
      description: {
        'es': 'Provincia costera famosa por sus vinos y paisajes.',
        'en': 'Coastal province famous for its wines and landscapes.',
      },
      capital: 'Quirihue',
      color: '#2196F3',
      cities: [
        City(
          id: 'quirihue',
          provinceId: 'itata',
          name: {
            'es': 'Quirihue',
            'en': 'Quirihue',
          },
          description: {
            'es': 'Capital provincial con tradición vitivinícola.',
            'en': 'Provincial capital with winemaking tradition.',
          },
          isCapital: true,
          culturalSites: [
            CulturalSite(
              id: 'vinas_quirihue',
              name: {
                'es': 'Viñas de Quirihue',
                'en': 'Quirihue Vineyards',
              },
              description: {
                'es': 'Tradicionales viñedos de la zona.',
                'en': 'Traditional vineyards of the area.',
              },
              type: 'vineyard',
              isUnlocked: false,
            ),
          ],
        ),
        City(
          id: 'cobquecura',
          provinceId: 'itata',
          name: {
            'es': 'Cobquecura',
            'en': 'Cobquecura',
          },
          description: {
            'es': 'Pueblo costero con hermosas playas.',
            'en': 'Coastal town with beautiful beaches.',
          },
          isCapital: false,
          culturalSites: [
            CulturalSite(
              id: 'iglesia_cobquecura',
              name: {
                'es': 'Iglesia de Cobquecura',
                'en': 'Cobquecura Church',
              },
              description: {
                'es': 'Histórica iglesia del pueblo.',
                'en': 'Historic village church.',
              },
              type: 'religious',
              isUnlocked: false,
            ),
          ],
        ),
      ],
    ),
    Province(
      id: 'punilla',
      name: {
        'es': 'Punilla',
        'en': 'Punilla',
      },
      description: {
        'es': 'Provincia andina con termas y naturaleza.',
        'en': 'Andean province with hot springs and nature.',
      },
      capital: 'San Carlos',
      color: '#FF9800',
      cities: [
        City(
          id: 'san_carlos',
          provinceId: 'punilla',
          name: {
            'es': 'San Carlos',
            'en': 'San Carlos',
          },
          description: {
            'es': 'Capital provincial en el valle central.',
            'en': 'Provincial capital in the central valley.',
          },
          isCapital: true,
          culturalSites: [
            CulturalSite(
              id: 'plaza_san_carlos',
              name: {
                'es': 'Plaza de San Carlos',
                'en': 'San Carlos Square',
              },
              description: {
                'es': 'Centro cívico de la ciudad.',
                'en': 'Civic center of the city.',
              },
              type: 'plaza',
              isUnlocked: true,
            ),
          ],
        ),
        City(
          id: 'san_fabian',
          provinceId: 'punilla',
          name: {
            'es': 'San Fabián',
            'en': 'San Fabián',
          },
          description: {
            'es': 'Comuna andina con termas naturales.',
            'en': 'Andean commune with natural hot springs.',
          },
          isCapital: false,
          culturalSites: [
            CulturalSite(
              id: 'termas_san_fabian',
              name: {
                'es': 'Termas de San Fabián',
                'en': 'San Fabián Hot Springs',
              },
              description: {
                'es': 'Aguas termales naturales.',
                'en': 'Natural hot springs.',
              },
              type: 'thermal',
              isUnlocked: false,
            ),
          ],
        ),
      ],
    ),
  ];

  static Province? getProvinceById(String id) {
    try {
      return provinces.firstWhere((province) => province.id == id);
    } catch (e) {
      return null;
    }
  }

  static City? getCityById(String id) {
    for (final province in provinces) {
      try {
        return province.cities.firstWhere((city) => city.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}
