import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:tesoro_regional/features/posts/domain/entities/post.dart';
import 'package:tesoro_regional/features/posts/domain/entities/comment.dart';
import 'package:tesoro_regional/features/posts/presentation/providers/post_providers.dart';
import 'package:tesoro_regional/features/posts/presentation/providers/comment_providers.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';
import 'package:tesoro_regional/features/profile/presentation/providers/profile_providers.dart';

class PostDetailPage extends ConsumerWidget {
  final Post post;

  const PostDetailPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.uid == post.userId;
    final commentsAsync = ref.watch(commentsProvider(post.id));
    final userLikedAsync = ref.watch(
      userLikedPostProvider((post.id, user?.uid ?? '')),
    );

    final postStreamAsync = ref.watch(userPostsProvider(post.userId));
    final currentPost = postStreamAsync.when(
      data: (posts) => posts.firstWhere(
            (p) => p.id == post.id,
        orElse: () => post,
      ),
      loading: () => post,
      error: (_, __) => post,
    );

    final totalMedia = currentPost.images.length + currentPost.videos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        elevation: 0,
        actions: [
          if (isOwner)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirm(context, ref);
                }
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          if (totalMedia > 0)
            _MediaCarouselWidget(
              images: currentPost.images,
              videos: currentPost.videos,
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (currentPost.userProfileImage != null && currentPost.userProfileImage!.isNotEmpty)
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: currentPost.userProfileImage!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      ),
                    const SizedBox(width: 12),
                    Text(
                      currentPost.alias != null && currentPost.alias!.isNotEmpty
                          ? currentPost.alias!
                          : (currentPost.userName ?? 'Usuario anónimo'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  currentPost.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentPost.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Tags
                if (currentPost.tags.isNotEmpty) ...[
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentPost.tags
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userLikedAsync.when(
                      data: (isLiked) {
                        return GestureDetector(
                          onTap: user?.uid != null
                              ? () => _toggleLike(
                            context,
                            ref,
                            currentPost.id,
                            user!.uid,
                            isLiked,
                          )
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentPost.likes.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isLiked ? Colors.red : Colors.black,
                                  fontWeight: isLiked
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => Row(
                        children: [
                          Icon(Icons.favorite_border,
                              color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(currentPost.likes.toString()),
                        ],
                      ),
                      error: (_, __) => Row(
                        children: [
                          Icon(Icons.favorite_border, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(currentPost.likes.toString()),
                        ],
                      ),
                    ),
                    Text(
                      currentPost.createdAt.toString().split('.')[0],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                const Text(
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(Icons.comment_outlined,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'Aún no hay comentarios',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final isCommentOwner = user?.uid == comment.userId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (comment.userProfileImage != null && comment.userProfileImage!.isNotEmpty)
                                          ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: comment.userProfileImage!,
                                              width: 28,
                                              height: 28,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                          ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment.userName ?? 'Usuario',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                comment.createdAt
                                                    .toString()
                                                    .split('.')[0],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCommentOwner)
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          Future.microtask(() async {
                                            await ref
                                                .read(commentRepositoryProvider)
                                                .deleteComment(
                                              currentPost.id,
                                              comment.id,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comment.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error cargando comentarios',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                if (user != null)
                  _CommentInputWidget(
                    postId: currentPost.id,
                    userId: user.uid,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(BuildContext context, WidgetRef ref, String postId,
      String userId, bool isLiked) async {
    try {
      if (isLiked) {
        await ref
            .read(postRepositoryProvider)
            .unlikePost(postId, userId)
            .then((result) {
          result.fold(
                (error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            ),
                (_) {},
          );
        });
      } else {
        await ref
            .read(postRepositoryProvider)
            .likePost(postId, userId)
            .then((result) {
          result.fold(
                (error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            ),
                (_) {},
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar post'),
        content: const Text('¿Estás seguro de que deseas eliminar este post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(context);

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Eliminando post...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              // Delete post in background
              await ref.read(postNotifierProvider.notifier).deletePost(post.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post eliminado exitosamente')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MediaCarouselWidget extends StatefulWidget {
  final List<String> images;
  final List<String> videos;

  const _MediaCarouselWidget({
    required this.images,
    required this.videos,
  });

  @override
  State<_MediaCarouselWidget> createState() => _MediaCarouselWidgetState();
}

class _MediaCarouselWidgetState extends State<_MediaCarouselWidget> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMedia = widget.images.length + widget.videos.length;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalMedia,
            itemBuilder: (context, index) {
              // Show videos first, then images
              if (index < widget.videos.length) {
                return GestureDetector(
                  onTap: () => _showFullScreenMedia(context, index, isVideo: true),
                  child: _VideoPlayerWidget(videoUrl: widget.videos[index]),
                );
              } else {
                final imageIndex = index - widget.videos.length;
                return GestureDetector(
                  onTap: () => _showFullScreenMedia(context, imageIndex, isVideo: false),
                  child: CachedNetworkImage(
                    imageUrl: widget.images[imageIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        if (totalMedia > 1)
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  totalMedia,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenMedia(BuildContext context, int index, {required bool isVideo}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: isVideo
                  ? _VideoPlayerWidget(videoUrl: widget.videos[index])
                  : InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
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
        height: 300,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (!_controller.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  size: 48,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentInputWidget extends ConsumerStatefulWidget {
  final String postId;
  final String userId;

  const _CommentInputWidget({
    required this.postId,
    required this.userId,
  });

  @override
  ConsumerState<_CommentInputWidget> createState() =>
      _CommentInputWidgetState();
}

class _CommentInputWidgetState extends ConsumerState<_CommentInputWidget> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    try {
      _commentController.dispose();
      super.dispose();
    } catch (e) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileStreamProvider);

    return TextField(
      controller: _commentController,
      decoration: InputDecoration(
        hintText: 'Escribe un comentario...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_commentController.text.trim().isNotEmpty) {
              final profile = profileAsync.value;

              final userName = '${profile?.name ?? ''} ${profile?.lastName ?? ''}'.trim();
              final alias = profile?.alias;

              final userProfileImage = profile?.profileImageUrl != null && profile!.profileImageUrl!.isNotEmpty
                  ? profile.profileImageUrl
                  : null;

              // Use alias for display if available, otherwise userName
              final displayName = alias != null && alias.isNotEmpty
                  ? alias
                  : (userName.isNotEmpty ? userName : 'Usuario');

              final comment = Comment(
                id: const Uuid().v4(),
                postId: widget.postId,
                userId: widget.userId,
                userName: displayName,
                userProfileImage: userProfileImage,
                content: _commentController.text.trim(),
                createdAt: DateTime.now(),
              );

              ref
                  .read(commentRepositoryProvider)
                  .addComment(comment)
                  .then((result) {
                result.fold(
                      (error) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  ),
                      (_) {
                    _commentController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comentario agregado')),
                    );
                  },
                );
              });
            }
          },
        ),
      ),
      maxLines: 3,
      minLines: 1,
    );
  }
}
