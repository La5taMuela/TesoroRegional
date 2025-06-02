import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocateMe;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocateMe,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _MapButton(
            icon: Icons.add,
            onPressed: onZoomIn,
          ),
          const SizedBox(height: 8),
          _MapButton(
            icon: Icons.remove,
            onPressed: onZoomOut,
          ),
          const SizedBox(height: 8),
          _MapButton(
            icon: Icons.my_location,
            onPressed: onLocateMe,
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
