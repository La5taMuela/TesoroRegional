import 'package:dartz/dartz.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_dto.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Exception, String>> createPost(Post post, List<String> imageFilePaths, List<String> videoFilePaths) async {
    try {
      final postDTO = PostDTO(
        id: post.id,
        userId: post.userId,
        title: post.title,
        content: post.content,
        location: post.location,
        images: post.images,
        videos: post.videos,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        likes: post.likes,
        tags: post.tags,
        userName: post.userName,
        alias: post.alias,
        userProfileImage: post.userProfileImage,
      );

      final postId = await remoteDataSource.createPost(postDTO, imageFilePaths, videoFilePaths);
      return Right(postId);
    } catch (e) {
      return Left(Exception('Error creando post: $e'));
    }
  }

  @override
  Future<Either<Exception, List<Post>>> getAllPosts() async {
    try {
      final posts = await remoteDataSource.getAllPosts();
      return Right(posts.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(Exception('Error obteniendo posts: $e'));
    }
  }

  @override
  Future<Either<Exception, List<Post>>> getUserPosts(String userId) async {
    try {
      final posts = await remoteDataSource.getUserPosts(userId);
      return Right(posts.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(Exception('Error obteniendo posts del usuario: $e'));
    }
  }

  @override
  Future<Either<Exception, Post>> getPostById(String postId) async {
    try {
      final post = await remoteDataSource.getPostById(postId);
      return Right(post.toEntity());
    } catch (e) {
      return Left(Exception('Error obteniendo post: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updatePost(Post post) async {
    try {
      final postDTO = PostDTO(
        id: post.id,
        userId: post.userId,
        title: post.title,
        content: post.content,
        location: post.location,
        images: post.images,
        videos: post.videos,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        likes: post.likes,
        tags: post.tags,
        userName: post.userName,
        alias: post.alias,
        userProfileImage: post.userProfileImage,
      );

      await remoteDataSource.updatePost(postDTO);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error actualizando post: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error eliminando post: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> likePost(String postId, String userId) async {
    try {
      await remoteDataSource.likePost(postId, userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error al dar like: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> unlikePost(String postId, String userId) async {
    try {
      await remoteDataSource.unlikePost(postId, userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error al remover like: $e'));
    }
  }

  @override
  Future<Either<Exception, List<Post>>> searchPostsByTags(List<String> tags) async {
    try {
      final posts = await remoteDataSource.searchPostsByTags(tags);
      return Right(posts.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(Exception('Error buscando posts: $e'));
    }
  }
}
