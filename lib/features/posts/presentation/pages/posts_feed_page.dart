import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/post_providers.dart';
import '../state/post_state.dart';
import '../widgets/post_card.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';

class PostsFeedPage extends ConsumerStatefulWidget {
  const PostsFeedPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PostsFeedPage> createState() => _PostsFeedPageState();
}

class _PostsFeedPageState extends ConsumerState<PostsFeedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postNotifierProvider.notifier).getAllPosts();
    });
  }

  void _navigateToCreatePost() {
    context.push('/create-post');
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
      body: postState is PostsLoaded
          ? postState.posts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay posts aún',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToCreatePost,
              icon: const Icon(Icons.add),
              label: const Text('Crear primer post'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          ref.read(postNotifierProvider.notifier).getAllPosts();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: postState.posts.length,
          itemBuilder: (context, index) {
            final post = postState.posts[index];
            return PostCard(
              post: post,
              currentUserId: currentUserId,
              onLike: (postId) {
                ref
                    .read(postNotifierProvider.notifier)
                    .likePost(postId, currentUserId);
              },
              onUnlike: (postId) {
                ref
                    .read(postNotifierProvider.notifier)
                    .unlikePost(postId, currentUserId);
              },
            );
          },
        ),
      )
          : postState is PostLoading
          ? const Center(child: CircularProgressIndicator())
          : postState is PostError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error,
                size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(postState.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(postNotifierProvider.notifier)
                    .getAllPosts();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : const SizedBox(),
    );
  }
}
