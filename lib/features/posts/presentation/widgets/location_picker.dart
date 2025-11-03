import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationPickerWidget extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;

  const LocationPickerWidget({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final Location location = Location();
  final addressController = TextEditingController();
  bool isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      final PermissionStatus permissionStatus =
          await location.requestPermission();

      if (permissionStatus == PermissionStatus.granted) {
        final LocationData currentLocation = await location.getLocation();
        if (mounted) {
          widget.onLocationSelected(
            currentLocation.latitude ?? 0,
            currentLocation.longitude ?? 0,
            addressController.text.isEmpty
                ? 'Mi ubicación actual'
                : addressController.text,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Seleccionar Ubicación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: 'Ingresa la dirección',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _getCurrentLocation,
                  icon: const Icon(Icons.location_searching),
                  label: const Text('Ubicación Actual'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onLocationSelected(
                      -33.4489,
                      -70.6693,
                      addressController.text.isEmpty
                          ? 'Santiago, Chile'
                          : addressController.text,
                    );
                  },
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
