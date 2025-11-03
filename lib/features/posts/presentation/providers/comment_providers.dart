import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/entities/comment.dart';
import '../../data/datasources/comment_remote_data_source.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/repositories/comment_repository.dart';

final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tesororegional',
  );
});

final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>(
      (ref) => CommentRemoteDataSourceImpl(ref.watch(_firestoreProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
      (ref) => CommentRepositoryImpl(ref.watch(commentRemoteDataSourceProvider)),
);

final commentsProvider = StreamProvider.family<List<Comment>, String>(
      (ref, postId) {
    final firestore = ref.watch(_firestoreProvider);

    return firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
        try {
          final data = doc.data();
          return Comment(
            id: doc.id,
            postId: data['postId'] as String? ?? '',
            userId: data['userId'] as String? ?? '',
            userName: data['userName'] as String? ?? 'Usuario',
            userProfileImage: data['userProfileImage'] != null
                ? data['userProfileImage'] as String
                : null,
            content: data['content'] as String? ?? '',
            createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        } catch (e) {
          return Comment(
            id: doc.id,
            postId: postId,
            userId: '',
            userName: 'Error',
            userProfileImage: null,
            content: 'Error al cargar comentario',
            createdAt: DateTime.now(),
          );
        }
      })
          .toList();
    });
  },
);
