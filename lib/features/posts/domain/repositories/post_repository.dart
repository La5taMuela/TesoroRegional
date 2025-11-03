import 'package:dartz/dartz.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Either<Exception, String>> createPost(Post post, List<String> imageFilePaths, List<String> videoFilePaths);

  // Obtener todos los posts
  Future<Either<Exception, List<Post>>> getAllPosts();

  // Obtener posts de un usuario específico
  Future<Either<Exception, List<Post>>> getUserPosts(String userId);

  // Obtener un post por ID
  Future<Either<Exception, Post>> getPostById(String postId);

  // Actualizar un post
  Future<Either<Exception, void>> updatePost(Post post);

  // Eliminar un post
  Future<Either<Exception, void>> deletePost(String postId);

  // Dar like a un post
  Future<Either<Exception, void>> likePost(String postId, String userId);

  // Remover like de un post
  Future<Either<Exception, void>> unlikePost(String postId, String userId);

  // Buscar posts por tags
  Future<Either<Exception, List<Post>>> searchPostsByTags(List<String> tags);
}
