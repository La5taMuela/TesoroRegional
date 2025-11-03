import 'package:dartz/dartz.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Exception, String>> addComment(Comment comment) async {
    try {
      final result = await remoteDataSource.addComment(comment);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Comment>>> getComments(String postId) async {
    try {
      final result = await remoteDataSource.getComments(postId);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> deleteComment(String postId, String commentId) async {
    try {
      await remoteDataSource.deleteComment(postId, commentId);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
