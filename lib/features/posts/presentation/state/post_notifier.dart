import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_location.dart';
import '../../domain/repositories/post_repository.dart';
import 'post_state.dart';

class PostNotifier extends StateNotifier<PostState> {
  final PostRepository postRepository;

  PostNotifier(this.postRepository) : super(const PostInitial());

  // Crear nuevo post
  Future<void> createPost({
    required String userId,
    required String title,
    required String content,
    required double latitude,
    required double longitude,
    required String address,
    required List<String> images,
    required List<String> tags,
    required List<String> imageFilePaths,
    List<String> videoFilePaths = const [],
    String? userName,
    String? alias, // Added alias parameter
    String? userProfileImage,
  }) async {
    state = const PostLoading();

    try {
      final postId = const Uuid().v4();
      final now = DateTime.now();

      final post = Post(
        id: postId,
        userId: userId,
        title: title,
        content: content,
        location: PostLocation(
          latitude: latitude,
          longitude: longitude,
          address: address,
        ),
        images: images,
        videos: videoFilePaths, // Updated to include video file paths
        createdAt: now,
        updatedAt: now,
        likes: 0,
        tags: tags,
        userName: userName,
        alias: alias, // Pass alias to post
        userProfileImage: userProfileImage,
      );

      final result = await postRepository.createPost(post, imageFilePaths, videoFilePaths);

      result.fold(
            (error) => state = PostError(error.toString()),
            (postId) => state = PostCreated(postId),
      );
    } catch (e) {
      state = PostError('Error al crear post: $e');
    }
  }

  // Obtener todos los posts
  Future<void> getAllPosts() async {
    state = const PostLoading();

    try {
      final result = await postRepository.getAllPosts();

      result.fold(
            (error) => state = PostError(error.toString()),
            (posts) => state = PostsLoaded(posts),
      );
    } catch (e) {
      state = PostError('Error al obtener posts: $e');
    }
  }

  // Obtener posts del usuario
  Future<void> getUserPosts(String userId) async {
    state = const PostLoading();

    try {
      final result = await postRepository.getUserPosts(userId);

      result.fold(
            (error) => state = PostError(error.toString()),
            (posts) => state = PostsLoaded(posts),
      );
    } catch (e) {
      state = PostError('Error al obtener posts: $e');
    }
  }

  // Dar like a un post
  Future<void> likePost(String postId, String userId) async {
    try {
      final result = await postRepository.likePost(postId, userId);

      result.fold(
            (error) => state = PostError(error.toString()),
            (_) => state = const PostSuccess('Like agregado'),
      );
    } catch (e) {
      state = PostError('Error al dar like: $e');
    }
  }

  // Remover like de un post
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final result = await postRepository.unlikePost(postId, userId);

      result.fold(
            (error) => state = PostError(error.toString()),
            (_) => state = const PostSuccess('Like removido'),
      );
    } catch (e) {
      state = PostError('Error al remover like: $e');
    }
  }

  // Buscar posts por tags
  Future<void> searchPostsByTags(List<String> tags) async {
    state = const PostLoading();

    try {
      final result = await postRepository.searchPostsByTags(tags);

      result.fold(
            (error) => state = PostError(error.toString()),
            (posts) => state = PostsLoaded(posts),
      );
    } catch (e) {
      state = PostError('Error al buscar posts: $e');
    }
  }

  // Eliminar post
  Future<void> deletePost(String postId) async {
    try {
      final result = await postRepository.deletePost(postId);

      result.fold(
            (error) => state = PostError(error.toString()),
            (_) => state = const PostSuccess('Post eliminado'),
      );
    } catch (e) {
      state = PostError('Error al eliminar post: $e');
    }
  }

  // Limpiar estado
  void clearState() {
    state = const PostInitial();
  }
}
