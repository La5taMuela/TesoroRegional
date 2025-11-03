import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/comment.dart';
import '../models/comment_dto.dart';

abstract class CommentRemoteDataSource {
  Future<String> addComment(Comment comment);
  Future<List<Comment>> getComments(String postId);
  Future<void> deleteComment(String postId, String commentId);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final FirebaseFirestore firestore;

  CommentRemoteDataSourceImpl(this.firestore);

  @override
  Future<String> addComment(Comment comment) async {
    try {
      final commentId = const Uuid().v4();
      final commentDTO = CommentDTO(
        id: commentId,
        postId: comment.postId,
        userId: comment.userId,
        userName: comment.userName,
        userProfileImage: comment.userProfileImage,
        content: comment.content,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('posts')
          .doc(comment.postId)
          .collection('comments')
          .doc(commentId)
          .set(commentDTO.toMap());

      return commentId;
    } catch (e) {
      throw Exception('Error al agregar comentario: $e');
    }
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    try {
      final querySnapshot = await firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CommentDTO.fromMap({...doc.data(), 'id': doc.id})
          .toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo comentarios: $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      throw Exception('Error eliminando comentario: $e');
    }
  }
}
