import 'package:flutter/material.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import '../../domain/entities/province.dart';

class PuzzlePieceCityCard extends StatelessWidget {
  final City city;
  final String provinceColor;
  final VoidCallback onTap;

  const PuzzlePieceCityCard({
    super.key,
    required this.city,
    required this.provinceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n?.locale.languageCode ?? 'es';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 200;

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(int.parse(provinceColor.replaceFirst('#', '0xFF')))
                        .withOpacity(0.1),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: PuzzlePiecePainter(
                  color: Color(int.parse(provinceColor.replaceFirst('#', '0xFF'))),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de capital si aplica
                      if (city.isCapital)
                        Container(
                          padding: EdgeInsets.all(isLargeScreen ? 8 : 6),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.star,
                            color: Colors.white,
                            size: isLargeScreen ? 20 : 16,
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(isLargeScreen ? 12 : 10),
                          decoration: BoxDecoration(
                            color: Color(int.parse(provinceColor.replaceFirst('#', '0xFF')))
                                .withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_city,
                            size: isLargeScreen ? 28 : 24,
                            color: Color(int.parse(provinceColor.replaceFirst('#', '0xFF'))),
                          ),
                        ),

                      SizedBox(height: isLargeScreen ? 16 : 12),

                      Text(
                        city.getName(languageCode),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (city.isCapital) ...[
                        SizedBox(height: isLargeScreen ? 6 : 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 12 : 8,
                            vertical: isLargeScreen ? 4 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n?.capital ?? 'Capital',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 12 : 10,
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: isLargeScreen ? 12 : 8),

                      Text(
                        city.getDescription(languageCode),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isLargeScreen ? 16 : 12),

                      // Estadísticas de sitios culturales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.place,
                            size: isLargeScreen ? 16 : 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${city.culturalSites.length} ${l10n?.culturalSites ?? 'sitios'}',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 12 : 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isLargeScreen ? 12 : 8),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 16 : 12,
                          vertical: isLargeScreen ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(provinceColor.replaceFirst('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n?.explore ?? 'Explorar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLargeScreen ? 14 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PuzzlePiecePainter extends CustomPainter {
  final Color color;

  PuzzlePiecePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Crear forma de pieza de puzzle
    final w = size.width;
    final h = size.height;
    const radius = 16.0;
    const knobSize = 12.0;

    // Comenzar desde la esquina superior izquierda
    path.moveTo(radius, 0);

    // Lado superior con knob
    path.lineTo(w * 0.4, 0);
    path.quadraticBezierTo(w * 0.4 + knobSize, -knobSize, w * 0.6, 0);
    path.lineTo(w - radius, 0);
    path.quadraticBezierTo(w, 0, w, radius);

    // Lado derecho
    path.lineTo(w, h * 0.4);
    path.quadraticBezierTo(w + knobSize, h * 0.4 + knobSize, w, h * 0.6);
    path.lineTo(w, h - radius);
    path.quadraticBezierTo(w, h, w - radius, h);

    // Lado inferior
    path.lineTo(w * 0.6, h);
    path.quadraticBezierTo(w * 0.6 - knobSize, h + knobSize, w * 0.4, h);
    path.lineTo(radius, h);
    path.quadraticBezierTo(0, h, 0, h - radius);

    // Lado izquierdo
    path.lineTo(0, h * 0.6);
    path.quadraticBezierTo(-knobSize, h * 0.6 - knobSize, 0, h * 0.4);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();

    canvas.drawPath(path, paint);

    // Dibujar borde
    paint
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
