import '../../domain/entities/post_location.dart';

class PostLocationDTO extends PostLocation {
  const PostLocationDTO({
    required super.latitude,
    required super.longitude,
    required super.address,
  });

  factory PostLocationDTO.fromMap(Map<String, dynamic> map) {
    return PostLocationDTO(
      latitude: map['latitude'] as double? ?? 0.0,
      longitude: map['longitude'] as double? ?? 0.0,
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
