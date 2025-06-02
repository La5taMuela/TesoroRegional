import 'package:tesoro_regional/features/puzzle/domain/entities/geo_position.dart';

class GeoPositionDto {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeName;

  const GeoPositionDto({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
  });

  factory GeoPositionDto.fromJson(Map<String, dynamic> json) {
    return GeoPositionDto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      placeName: json['placeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeName': placeName,
    };
  }

  GeoPositionDto copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
  }) {
    return GeoPositionDto(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeName: placeName ?? this.placeName,
    );
  }

  // Convert to domain entity
  GeoPosition toDomain() {
    return GeoPosition(
      latitude: latitude,
      longitude: longitude,
      address: address,
      placeName: placeName,
    );
  }

  // Create from domain entity
  factory GeoPositionDto.fromDomain(GeoPosition position) {
    return GeoPositionDto(
      latitude: position.latitude,
      longitude: position.longitude,
      address: position.address,
      placeName: position.placeName,
    );
  }
}
