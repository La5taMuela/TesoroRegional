import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/post_dto.dart';

abstract class PostRemoteDataSource {
  Future<String> createPost(PostDTO post, List<String> imageFilePaths, List<String> videoFilePaths);
  Future<List<PostDTO>> getAllPosts();
  Future<List<PostDTO>> getUserPosts(String userId);
  Future<PostDTO> getPostById(String postId);
  Future<void> updatePost(PostDTO post);
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  Future<List<PostDTO>> searchPostsByTags(List<String> tags);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  PostRemoteDataSourceImpl(this.firestore, this.storage);

  @override
  Future<String> createPost(PostDTO post, List<String> imageFilePaths, List<String> videoFilePaths) async {
    try {
      final postId = post.id.isEmpty ? const Uuid().v4() : post.id;

      List<String> uploadedImageUrls = [];
      for (int i = 0; i < imageFilePaths.length; i++) {
        final imagePath = imageFilePaths[i];
        final file = File(imagePath);

        final storageRef = storage.ref().child('posts/$postId/image_$i.jpg');
        final uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        await uploadTask;
        final downloadUrl = await storageRef.getDownloadURL();
        uploadedImageUrls.add(downloadUrl);
      }

      List<String> uploadedVideoUrls = [];
      for (int i = 0; i < videoFilePaths.length; i++) {
        final videoPath = videoFilePaths[i];
        final file = File(videoPath);

        final storageRef = storage.ref().child('posts/$postId/video_$i.mp4');
        final uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: 'video/mp4'),
        );

        await uploadTask;
        final downloadUrl = await storageRef.getDownloadURL();
        uploadedVideoUrls.add(downloadUrl);
      }

      final postData = {
        'id': postId,
        'userId': post.userId,
        'title': post.title,
        'content': post.content,
        'location': post.location.toMap(),
        'images': uploadedImageUrls,
        'videos': uploadedVideoUrls,
        'createdAt': post.createdAt,
        'updatedAt': post.updatedAt,
        'likes': post.likes,
        'tags': post.tags,
        'userName': post.userName,
        'alias': post.alias,
        'userProfileImage': post.userProfileImage,
      };

      await firestore.collection('posts').doc(postId).set(postData);
      return postId;
    } catch (e) {
      throw Exception('Error creando post: $e');
    }
  }

  @override
  Future<List<PostDTO>> getAllPosts() async {
    try {
      final querySnapshot = await firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostDTO.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo posts: $e');
    }
  }

  @override
  Future<List<PostDTO>> getUserPosts(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostDTO.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo posts del usuario: $e');
    }
  }

  @override
  Future<PostDTO> getPostById(String postId) async {
    try {
      final doc = await firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        throw Exception('Post no encontrado');
      }
      return PostDTO.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Error obteniendo post: $e');
    }
  }

  @override
  Future<void> updatePost(PostDTO post) async {
    try {
      await firestore.collection('posts').doc(post.id).update(post.toMap());
    } catch (e) {
      throw Exception('Error actualizando post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);

      // Delete all likes
      final likesSnapshot = await postRef.collection('likes').get();
      for (var doc in likesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all comments
      final commentsSnapshot = await postRef.collection('comments').get();
      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      try {
        final storageRef = storage.ref().child('posts/$postId');
        final files = await storageRef.listAll();
        for (var file in files.items) {
          await file.delete();
        }
      } catch (e) {
        print('[v0] No media found for post $postId, continuing...');
      }

      // Delete post document
      await postRef.delete();
    } catch (e) {
      throw Exception('Error eliminando post: $e');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final likesRef = postRef.collection('likes').doc(userId);

      final likeDoc = await likesRef.get();
      if (likeDoc.exists) {
        return; // Ya tiene like, no hacer nada
      }

      await firestore.runTransaction((transaction) async {
        // Read first
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post no encontrado');
        }

        // Then write
        final currentLikes = postDoc.data()?['likes'] ?? 0;
        transaction.set(likesRef, {'likedAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {'likes': currentLikes + 1});
      });
    } catch (e) {
      throw Exception('Error al dar like: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final postRef = firestore.collection('posts').doc(postId);
      final likesRef = postRef.collection('likes').doc(userId);

      final likeDoc = await likesRef.get();
      if (!likeDoc.exists) {
        return; // No tiene like, no hacer nada
      }

      await firestore.runTransaction((transaction) async {
        // Read first
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post no encontrado');
        }

        // Then write
        final currentLikes = postDoc.data()?['likes'] ?? 0;
        transaction.delete(likesRef);
        transaction.update(postRef, {'likes': currentLikes > 0 ? currentLikes - 1 : 0});
      });
    } catch (e) {
      throw Exception('Error al remover like: $e');
    }
  }

  @override
  Future<List<PostDTO>> searchPostsByTags(List<String> tags) async {
    try {
      final querySnapshot = await firestore
          .collection('posts')
          .where('tags', arrayContainsAny: tags)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PostDTO.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error buscando posts por tags: $e');
    }
  }
}
