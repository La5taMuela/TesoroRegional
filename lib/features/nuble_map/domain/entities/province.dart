class Province {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String capital;
  final String color;
  final List<City> cities;

  const Province({
    required this.id,
    required this.name,
    required this.description,
    required this.capital,
    required this.color,
    required this.cities,
  });

  String getName(String languageCode) {
    return name[languageCode] ?? name['es'] ?? id;
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['es'] ?? '';
  }
}

class City {
  final String id;
  final String provinceId;
  final Map<String, String> name;
  final Map<String, String> description;
  final bool isCapital;
  final List<CulturalSite> culturalSites;

  const City({
    required this.id,
    required this.provinceId,
    required this.name,
    required this.description,
    required this.isCapital,
    required this.culturalSites,
  });

  String getName(String languageCode) {
    return name[languageCode] ?? name['es'] ?? id;
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['es'] ?? '';
  }
}

class CulturalSite {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String type;
  final bool isUnlocked;

  const CulturalSite({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isUnlocked,
  });

  String getName(String languageCode) {
    return name[languageCode] ?? name['es'] ?? id;
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['es'] ?? '';
  }
}
