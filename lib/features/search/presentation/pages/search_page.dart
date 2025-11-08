import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tesoro_regional/features/posts/domain/entities/post.dart';
import 'package:tesoro_regional/features/posts/presentation/providers/post_providers.dart';
import 'package:tesoro_regional/features/posts/presentation/pages/post_detail_page.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';
import 'package:tesoro_regional/core/widgets/custom_bottom_nav_bar.dart';
import 'package:video_player/video_player.dart';

class SearchPage extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const SearchPage({
    Key? key,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedTags = [];

  final List<String> _popularTags = [
    'Naturaleza',
    'Cultura',
    'Gastronomía',
    'Historia',
    'Aventura',
    'Arquitectura',
    'Tradiciones',
    'Paisajes',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPostsAsync = ref.watch(allPostsProvider);
    final user = ref.watch(currentUserProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explorar Publicaciones'),
          elevation: 0,
          automaticallyImplyLeading: !widget.showBottomNav, // Mostrar back button solo si no hay navbar
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por título, contenido o tags...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _popularTags.length,
                itemBuilder: (context, index) {
                  final tag = _popularTags[index];
                  final isSelected = _selectedTags.contains(tag);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue[700],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue[700] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: allPostsAsync.when(
                data: (posts) {
                  final filteredPosts = posts.where((post) {
                    final title = post.title.toLowerCase();
                    final content = post.content.toLowerCase();
                    final tags = post.tags.map((t) => t.toLowerCase()).toList();
                    final searchLower = _searchQuery.toLowerCase();

                    final matchesSearch = _searchQuery.isEmpty ||
                        title.contains(searchLower) ||
                        content.contains(searchLower) ||
                        tags.any((t) => t.contains(searchLower));

                    final matchesTags = _selectedTags.isEmpty ||
                        _selectedTags.any((selectedTag) =>
                            tags.contains(selectedTag.toLowerCase()));

                    return matchesSearch && matchesTags;
                  }).toList();

                  if (filteredPosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedTags.isEmpty
                                ? 'No hay publicaciones aún'
                                : 'No se encontraron resultados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_selectedTags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedTags.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Limpiar filtros'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(post: post),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.videos.isNotEmpty || post.images.isNotEmpty)
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: post.videos.isNotEmpty
                                          ? _VideoThumbnailPreview(videoUrl: post.videos.first)
                                          : CachedNetworkImage(
                                        imageUrl: post.images.first,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                        placeholder: (context, url) => Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              height: 200,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image_not_supported),
                                            ),
                                      ),
                                    ),
                                    if (post.videos.length + post.images.length > 1)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.collections,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${post.videos.length + post.images.length}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (post.userProfileImage != null && post.userProfileImage!.isNotEmpty)
                                          ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: post.userProfileImage!,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
                                          ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.alias != null && post.alias!.isNotEmpty
                                                    ? post.alias!
                                                    : (post.userName ?? 'Usuario anónimo'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                post.createdAt
                                                    .toString()
                                                    .split('.')[0],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      post.content,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (post.tags.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: post.tags.take(3).map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '#$tag',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 11,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.favorite_border,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              post.likes.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Ver más →',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error cargando publicaciones: $error',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.showBottomNav
            ? const CustomBottomNavBar(currentIndex: 1)
            : null,
      ),
    );
  }
}

class _VideoThumbnailPreview extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnailPreview({required this.videoUrl});

  @override
  State<_VideoThumbnailPreview> createState() => _VideoThumbnailPreviewState();
}

class _VideoThumbnailPreviewState extends State<_VideoThumbnailPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(_controller),
          Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}