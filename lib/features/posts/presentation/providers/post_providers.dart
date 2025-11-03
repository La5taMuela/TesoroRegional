import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../data/datasources/post_remote_data_source.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post_location.dart';
import '../../domain/repositories/post_repository.dart';
import '../state/post_notifier.dart';
import '../state/post_state.dart';
import '../../domain/entities/post.dart';

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tesororegional',
  );
  final storage = FirebaseStorage.instance;
  return PostRemoteDataSourceImpl(firestore, storage);
});

// Repository provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final dataSource = ref.watch(postRemoteDataSourceProvider);
  return PostRepositoryImpl(dataSource);
});

// State notifier provider
final postNotifierProvider =
StateNotifierProvider<PostNotifier, PostState>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostNotifier(repository);
});

final userPostsProvider = StreamProvider.family<List<Post>, String>((ref, userId) {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tesororegional',
  );

  return firestore
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) {
      final data = doc.data();
      return Post(
        id: data['id'] ?? '',
        userId: data['userId'] ?? '',
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        location: PostLocation(
          latitude: data['location']?['latitude'] ?? 0,
          longitude: data['location']?['longitude'] ?? 0,
          address: data['location']?['address'] ?? '',
        ),
        images: List<String>.from(data['images'] ?? []),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        likes: data['likes'] ?? 0,
        tags: List<String>.from(data['tags'] ?? []),
        userName: data['userName'],
        userProfileImage: data['userProfileImage'],
      );
    })
        .toList();
  });
});

final userLikedPostProvider =
StreamProvider.family<bool, (String, String)>((ref, args) {
  final (postId, userId) = args;
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tesororegional',
  );

  return firestore
      .collection('posts')
      .doc(postId)
      .collection('likes')
      .doc(userId)
      .snapshots()
      .map((snapshot) => snapshot.exists);
});

final allPostsProvider = StreamProvider<List<Post>>((ref) {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tesororegional',
  );

  return firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) {
      final data = doc.data();
      return Post(
        id: data['id'] ?? '',
        userId: data['userId'] ?? '',
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        location: PostLocation(
          latitude: data['location']?['latitude'] ?? 0,
          longitude: data['location']?['longitude'] ?? 0,
          address: data['location']?['address'] ?? '',
        ),
        images: List<String>.from(data['images'] ?? []),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        likes: data['likes'] ?? 0,
        tags: List<String>.from(data['tags'] ?? []),
        userName: data['userName'],
        userProfileImage: data['userProfileImage'],
      );
    })
        .toList();
  });
});
