import 'package:flutter/material.dart';

abstract class LocationService {
  Future<bool> isLocationEnabled();
  Future<bool> requestLocationPermission();
  Future<LocationData?> getCurrentLocation();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationEnabled() async {
    // Simplified implementation
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    // Simplified implementation
    return true;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    // Simplified implementation - return mock data
    return LocationData(
      latitude: -36.6062,
      longitude: -72.1025,
      accuracy: 10.0,
    );
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
}
