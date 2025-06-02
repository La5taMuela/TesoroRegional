import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';
import 'package:tesoro_regional/core/services/content/story_service.dart';
import 'package:tesoro_regional/core/services/storage/progress_storage_service.dart';
import 'package:tesoro_regional/features/stories/domain/entities/story.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final StoryService _storyService = StoryService();
  final ProgressStorageService _progressService = ProgressStorageService();

  List<Story> _stories = [];
  List<String> _cities = [];
  List<String> _readStories = [];
  String _selectedCity = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stories.isEmpty && _isLoading) {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final l10n = AppLocalizations.of(context);
      final languageCode = l10n?.locale.languageCode ?? 'es';

      // Cargar historias y ciudades
      final stories = await _storyService.loadStories(languageCode);
      final cities = await _storyService.getCities(languageCode);
      final readStories = await _progressService.getReadStories();

      if (mounted) {
        setState(() {
          _stories = stories;
          _cities = ['Todas', ...cities];
          _selectedCity = _cities.isNotEmpty ? _cities.first : 'Todas';
          _readStories = readStories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar las historias: $e';
        });
      }
    }
  }

  List<Story> get _filteredStories {
    List<Story> filtered = _stories;

    if (_selectedCity != 'Todas') {
      filtered = filtered.where((story) => story.city == _selectedCity).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((story) =>
      story.title.toLowerCase().contains(query) ||
          story.description.toLowerCase().contains(query) ||
          story.city.toLowerCase().contains(query) ||
          story.category.toLowerCase().contains(query)).toList();
    }

    return filtered;
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
          title: Text(l10n?.stories ?? 'Historias'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadContent,
              tooltip: l10n?.refresh ?? 'Actualizar',
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
            Text('Cargando historias...'),
          ],
        ),
      );
    }

    if (_stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n?.noStoriesAvailable ?? 'No hay historias disponibles',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContent,
              child: Text(l10n?.retry ?? 'Reintentar'),
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
        // Search and filter section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n?.searchStories ?? 'Buscar historias...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // City filter
              Row(
                children: [
                  Text(
                    l10n?.filterByCity ?? 'Filtrar por ciudad:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Stories list
        Expanded(
          child: _filteredStories.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l10n?.noStoriesFound ?? 'No se encontraron historias',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadContent,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredStories.length,
              itemBuilder: (context, index) {
                final story = _filteredStories[index];
                final isRead = _readStories.contains(story.id);
                return _StoryCard(
                  story: story,
                  isRead: isRead,
                  onTap: () => _showStoryDetail(story),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showStoryDetail(Story story) async {
    // Marcar como leída
    await _progressService.markStoryAsRead(story.id);
    setState(() {
      if (!_readStories.contains(story.id)) {
        _readStories.add(story.id);
      }
    });

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _StoryDetailSheet(story: story),
      );
    }
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final bool isRead;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.isRead,
    required this.onTap,
  });

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
                      story.city,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      story.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.read ?? 'Leída',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                story.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isRead ? Colors.grey[600] : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                story.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${story.readingTime} ${l10n?.minutes ?? 'min'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      story.author,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    l10n?.readMore ?? 'Leer más',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryDetailSheet extends StatelessWidget {
  final Story story;

  const _StoryDetailSheet({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          story.city,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          story.category,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Meta info
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        story.author,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${story.readingTime} min',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Image placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      image: story.imageAsset.isNotEmpty
                          ? DecorationImage(
                        image: AssetImage(story.imageAsset),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Si la imagen no se puede cargar, se mostrará el placeholder
                        },
                      )
                          : null,
                    ),
                    child: story.imageAsset.isEmpty
                        ? const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.grey),
                    )
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // Content
                  Text(
                    story.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Publication date
                  Text(
                    'Publicado: ${_formatDate(story.publishDate)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
