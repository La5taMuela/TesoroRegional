import 'package:equatable/equatable.dart';

class PostLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String address;

  const PostLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  // Crear desde Map de Firestore
  factory PostLocation.fromMap(Map<String, dynamic> map) {
    return PostLocation(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address];
}
