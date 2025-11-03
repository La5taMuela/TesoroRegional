import 'package:location/location.dart';

abstract class LocationService {
  Future<bool> isLocationEnabled();
  Future<bool> requestLocationPermission();
  Future<LocationData?> getCurrentLocation();
  Stream<LocationData> getLocationStream();
}

class LocationServiceImpl implements LocationService {
  final Location _location = Location();

  @override
  Future<bool> isLocationEnabled() async {
    return await _location.serviceEnabled();
  }

  @override
  Future<bool> requestLocationPermission() async {
    PermissionStatus permission = await _location.hasPermission();

    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission == PermissionStatus.denied) {
        return false;
      }
    }

    if (permission == PermissionStatus.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        // Return mock data for Diguillín (Chillán) if no permission
        return LocationData(
          latitude: -36.6062,
          longitude: -72.1025,
          accuracy: 10.0,
        );
      }

      final locationData = await _location.getLocation();

      return LocationData(
        latitude: locationData.latitude ?? -36.6062,
        longitude: locationData.longitude ?? -72.1025,
        accuracy: locationData.accuracy ?? 10.0,
      );
    } catch (e) {
      // Return mock data for Diguillín region if real location fails
      return LocationData(
        latitude: -36.6062,
        longitude: -72.1025,
        accuracy: 10.0,
      );
    }
  }

  @override
  Stream<LocationData> getLocationStream() {
    try {
      return _location.onLocationChanged.map((locationData) => LocationData(
        latitude: locationData.latitude ?? -36.6062,
        longitude: locationData.longitude ?? -72.1025,
        accuracy: locationData.accuracy ?? 10.0,
      )).handleError((error) {
        // Return mock data stream if real location fails
        return Stream.value(LocationData(
          latitude: -36.6062,
          longitude: -72.1025,
          accuracy: 10.0,
        ));
      });
    } catch (e) {
      // Return mock data stream if location fails
      return Stream.periodic(const Duration(seconds: 5), (count) {
        return LocationData(
          latitude: -36.6062,
          longitude: -72.1025,
          accuracy: 10.0,
        );
      });
    }
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}
