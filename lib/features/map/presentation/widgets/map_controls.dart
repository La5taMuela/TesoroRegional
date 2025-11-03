import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapControls extends StatelessWidget {
  final Function(LatLng)? onLocationUpdated;
  final Function(double)? onZoomChanged;
  final bool isFullScreen;

  const MapControls({
    super.key,
    this.onLocationUpdated,
    this.onZoomChanged,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapButton(
          icon: Icons.add,
          onPressed: () {
            onZoomChanged?.call(1.0);
          },
          tooltip: 'Zoom In',
        ),
        const SizedBox(height: 8),
        _MapButton(
          icon: Icons.remove,
          onPressed: () {
            onZoomChanged?.call(-1.0);
          },
          tooltip: 'Zoom Out',
        ),
        const SizedBox(height: 8),
        _MapButton(
          icon: Icons.my_location,
          onPressed: () async {
            try {
              final locationService = Location();
              final serviceEnabled = await locationService.serviceEnabled();
              if (!serviceEnabled) {
                final serviceRequestResult = await locationService.requestService();
                if (!serviceRequestResult) {
                  print('Location service not enabled');
                  return;
                }
              }

              var permissionStatus = await locationService.hasPermission();
              if (permissionStatus == PermissionStatus.denied) {
                permissionStatus = await locationService.requestPermission();
                if (permissionStatus != PermissionStatus.granted) {
                  print('Location permission not granted');
                  return;
                }
              }

              final position = await locationService.getLocation();
              if (position.latitude != null && position.longitude != null) {
                final latLng = LatLng(position.latitude!, position.longitude!);
                onLocationUpdated?.call(latLng);
              }
            } catch (e) {
              print('Error getting location: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not get current location.'),
                ),
              );
            }
          },
          tooltip: 'My Location',
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const _MapButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, size: isLargeScreen ? 28 : 24),
          iconSize: isLargeScreen ? 28 : 24,
          onPressed: onPressed,
          color: Theme.of(context).primaryColor,
          splashRadius: isLargeScreen ? 28 : 20,
        ),
      ),
    );
  }
}