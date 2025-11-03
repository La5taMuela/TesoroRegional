import 'package:flutter/material.dart';
import 'package:tesoro_regional/features/map/domain/entities/strategic_point.dart';

class PieceInfoSheet extends StatefulWidget {
  final StrategicPoint point;
  final VoidCallback onUnlock;
  final bool isInRange;
  final String distance;
  final VoidCallback onClose;

  const PieceInfoSheet({
    super.key,
    required this.point,
    required this.onUnlock,
    required this.isInRange,
    required this.distance,
    required this.onClose,
  });

  @override
  State<PieceInfoSheet> createState() => _PieceInfoSheetState();
}

class _PieceInfoSheetState extends State<PieceInfoSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  IconData _getIconForPoint(StrategicPoint point) {
    if (point.name.toLowerCase().contains('plaza')) return Icons.park;
    if (point.name.toLowerCase().contains('mercado')) return Icons.store;
    if (point.name.toLowerCase().contains('catedral')) return Icons.church;
    if (point.name.toLowerCase().contains('inacap')) return Icons.school;
    return Icons.place;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: -screenHeight * _slideAnimation.value,
          left: 0,
          right: 0,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.6,
            ),
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              elevation: 16,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de arrastre
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Contenido principal
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado con icono y título
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: widget.point.isUnlocked
                                        ? Colors.green.withOpacity(0.1)
                                        : Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _getIconForPoint(widget.point),
                                    size: 32,
                                    color: widget.point.isUnlocked
                                        ? Colors.green
                                        : Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.point.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.point.isUnlocked
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              widget.point.isUnlocked
                                                  ? Icons.check_circle
                                                  : Icons.location_on,
                                              size: 16,
                                              color: widget.point.isUnlocked
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              widget.point.isUnlocked
                                                  ? 'Desbloqueado'
                                                  : 'Por descubrir',
                                              style: TextStyle(
                                                color: widget.point.isUnlocked
                                                    ? Colors.green
                                                    : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _closeSheet,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Descripción
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Descripción',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.point.description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Estado de desbloqueo
                            if (widget.point.isUnlocked)
                              _buildUnlockedIndicator()
                            else
                              _buildUnlockSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnlockedIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Pieza desbloqueada!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Has descubierto este sitio cultural exitosamente',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón de desbloqueo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: widget.isInRange
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              foregroundColor: Colors.white,
              elevation: widget.isInRange ? 2 : 0,
            ),
            onPressed: widget.isInRange ? widget.onUnlock : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isInRange ? Icons.lock_open : Icons.lock,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isInRange
                      ? 'DESBLOQUEAR PIEZA'
                      : 'ACÉRCATE PARA DESBLOQUEAR',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Información de distancia si no está en rango
        if (!widget.isInRange) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Información de distancia',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Distancia actual: ${widget.distance}m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Distancia requerida: ${widget.point.activationRadius.toInt()}m',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                // Barra de progreso de distancia
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso de proximidad',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _calculateProximityProgress(),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_calculateProximityProgress() * 100).toInt()}% del camino',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  double _calculateProximityProgress() {
    final currentDistance = double.tryParse(widget.distance) ?? double.infinity;
    final requiredDistance = widget.point.activationRadius;

    if (currentDistance <= requiredDistance) return 1.0;

    // Calculate progress based on a reasonable maximum distance (e.g., 1000m)
    const maxDistance = 1000.0;
    final progress = 1.0 - (currentDistance / maxDistance);
    return progress.clamp(0.0, 1.0);
  }

  Color _getProgressColor() {
    final progress = _calculateProximityProgress();
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
