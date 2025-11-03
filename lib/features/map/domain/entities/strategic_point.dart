// strategic_point.dart
class StrategicPoint {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double activationRadius; // en metros
  final String iconUrl;
  final String? puzzlePieceId; // ID de la pieza de rompecabezas relacionada
  final bool isUnlocked; // Nuevo campo para estado de desbloqueo

  const StrategicPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.activationRadius = 100.0,
    required this.iconUrl,
    this.puzzlePieceId,
    this.isUnlocked = false,
  });

  StrategicPoint copyWith({
    bool? isUnlocked,
  }) {
    return StrategicPoint(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      activationRadius: activationRadius,
      iconUrl: iconUrl,
      puzzlePieceId: puzzlePieceId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StrategicPoint &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}