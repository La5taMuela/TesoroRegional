import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/core/services/content/mission_service.dart';
import 'package:tesoro_regional/core/services/storage/progress_storage_service.dart';
import 'package:tesoro_regional/features/missions/domain/entities/mission.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  List<Mission> _missions = [];
  final MissionService _missionService = MissionService();
  final ProgressStorageService _progressService = ProgressStorageService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_missions.isEmpty && _isLoading) {
      _loadMissions();
    }
  }

  Future<void> _loadMissions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final l10n = AppLocalizations.of(context);
      final languageCode = l10n?.locale.languageCode ?? 'es';

      // Cargar misiones
      final missions = await _missionService.loadMissions(languageCode);

      // Cargar progreso guardado para cada misión
      for (var mission in missions) {
        final savedProgress = await _progressService.loadMissionProgress(mission.id);
        if (savedProgress != null && savedProgress.length == mission.points.length) {
          for (int i = 0; i < mission.points.length; i++) {
            mission.points[i].isCompleted = savedProgress[i];
          }
        }
      }

      if (mounted) {
        setState(() {
          _missions = missions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading missions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar las misiones: $e';
        });
      }
    }
  }

  Future<void> _saveMissionProgress(Mission mission) async {
    final progress = mission.points.map((point) => point.isCompleted).toList();
    await _progressService.saveMissionProgress(mission.id, progress);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.missions ?? 'Misiones Turísticas'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMissions,
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando misiones...'),
          ],
        ),
      );
    }

    if (_missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay misiones disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMissions,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadMissions,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _missions.length,
              itemBuilder: (context, index) {
                final mission = _missions[index];
                return _MissionCard(
                  mission: mission,
                  onTap: () => _showMissionDetail(mission),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showMissionDetail(Mission mission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MissionDetailSheet(
        mission: mission,
        onPointToggle: (pointIndex) async {
          setState(() {
            mission.points[pointIndex].isCompleted = !mission.points[pointIndex].isCompleted;
          });

          // Guardar progreso
          await _saveMissionProgress(mission);

          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// El resto de las clases permanecen igual...
class _MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;

  const _MissionCard({
    required this.mission,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (mission.difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return Colors.green;
      case 'medio':
      case 'medium':
        return Colors.orange;
      case 'difícil':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mission.city,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mission.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                mission.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mission.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    mission.estimatedTime,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${mission.completedPoints}/${mission.points.length} ${l10n?.points ?? 'puntos'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: mission.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  mission.isCompleted ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
              if (mission.isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mission.reward,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionDetailSheet extends StatelessWidget {
  final Mission mission;
  final Function(int) onPointToggle;

  const _MissionDetailSheet({
    required this.mission,
    required this.onPointToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.location_on,
                        label: mission.city,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.access_time,
                        label: mission.estimatedTime,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        l10n?.progress ?? 'Progreso:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text('${mission.completedPoints}/${mission.points.length}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: mission.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.isCompleted ? Colors.green : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n?.pointsToVisit ?? 'Puntos a visitar:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...mission.points.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    return _PointTile(
                      point: point,
                      onToggle: () => onPointToggle(index),
                    );
                  }),
                  if (mission.isCompleted) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.missionCompleted ?? '¡Misión Completada!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n?.youHaveObtained ?? 'Has obtenido'}: ${mission.reward}',
                            style: const TextStyle(color: Colors.amber),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  final MissionPoint point;
  final VoidCallback onToggle;

  const _PointTile({
    required this.point,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: point.isCompleted ? Colors.green : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: point.isCompleted ? Colors.green : Colors.transparent,
              border: Border.all(
                color: point.isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: point.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          point.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: point.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          point.description,
          style: TextStyle(
            color: Colors.grey[600],
            decoration: point.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        onTap: onToggle,
      ),
    );
  }
}
