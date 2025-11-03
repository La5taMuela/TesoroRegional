import 'package:dartz/dartz.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Either<Exception, String>> addComment(Comment comment);
  Future<Either<Exception, List<Comment>>> getComments(String postId);
  Future<Either<Exception, void>> deleteComment(String postId, String commentId);
}
