import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/province.dart';

class InteractiveNubleMap extends StatefulWidget {
  final Function(Province) onProvinceSelected;
  final String? selectedProvinceId;
  final List<String> collectedProvinces;

  const InteractiveNubleMap({
    super.key,
    required this.onProvinceSelected,
    this.selectedProvinceId,
    required this.collectedProvinces,
  });

  @override
  State<InteractiveNubleMap> createState() => _InteractiveNubleMapState();
}

class _InteractiveNubleMapState extends State<InteractiveNubleMap> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              // Mapa base con las 3 provincias
              _buildProvinceSvg('diguillin'),
              _buildProvinceSvg('itata'),
              _buildProvinceSvg('punilla'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceSvg(String provinceId) {
    final isCollected = widget.collectedProvinces.contains(provinceId);

    // Determinar el color basado en el estado y la provincia
    Color svgColor;
    switch (provinceId) {
      case 'diguillin':
        svgColor = isCollected
            ? const Color(0xFF1976D2) // Azul más intenso cuando completado
            : const Color(0xFF90CAF9); // Azul claro cuando no completado
        break;
      case 'itata':
        svgColor = isCollected
            ? const Color(0xFFE65100) // Naranja más intenso cuando completado
            : const Color(0xFFFFCC02); // Naranja claro cuando no completado
        break;
      case 'punilla':
        svgColor = isCollected
            ? const Color(0xFF7B1FA2) // Púrpura más intenso cuando completado
            : const Color(0xFFBA68C8); // Púrpura claro cuando no completado
        break;
      default:
        svgColor = Colors.grey;
    }

    return Positioned.fill(
      child: SvgPicture.asset(
        'assets/nuble_svg/$provinceId.svg',
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          svgColor.withOpacity(0.8),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
