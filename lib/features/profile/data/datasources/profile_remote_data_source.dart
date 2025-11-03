import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tesoro_regional/features/profile/data/models/user_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDTO?> getProfile(String userId);
  Stream<UserProfileDTO?> watchProfile(String userId);
  Future<void> saveProfile(UserProfileDTO profile);
  Future<String> uploadProfileImage(String userId, File imageFile);
  Future<void> deleteProfileImage(String imageUrl);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'tesororegional'),
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<UserProfileDTO?> getProfile(String userId) async {
    try {
      print('[v0] getProfile - userId: $userId');
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        print('[v0] Timeout al obtener datos del usuario');
        throw TimeoutException('Timeout al cargar datos del usuario');
      });

      if (doc.exists) {
        print('[v0] Datos del usuario obtenidos: ${doc.data()}');
        return UserProfileDTO.fromFirestore(doc);
      }

      print('[v0] Usuario no encontrado en Firestore');
      return null;
    } catch (e) {
      print('[v0] Error al obtener el perfil: $e');
      throw Exception('Error al obtener el perfil: $e');
    }
  }

  @override
  Stream<UserProfileDTO?> watchProfile(String userId) {
    print('[v0] watchProfile - userId: $userId');
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        print('[v0] Stream: Datos del usuario actualizados: ${doc.data()}');
        return UserProfileDTO.fromFirestore(doc);
      }
      print('[v0] Stream: Usuario no encontrado en Firestore');
      return null;
    }).handleError((error) {
      print('[v0] Stream: Error al escuchar cambios del perfil: $error');
      return null;
    });
  }

  @override
  Future<void> saveProfile(UserProfileDTO profile) async {
    try {
      print('[v0] saveProfile - userId: ${profile.id}');
      print('[v0] Datos a guardar: ${profile.toFirestore()}');

      await _firestore.collection('users').doc(profile.id).set(profile.toFirestore(), SetOptions(merge: true));

      print('[v0] Perfil guardado exitosamente');
    } catch (e) {
      print('[v0] Error al guardar el perfil: $e');
      throw Exception('Error al guardar el perfil: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      print('[v0] uploadProfileImage - userId: $userId');
      final ref = _storage.ref().child('users/$userId/images/avatar.jpg');

      print('[v0] Subiendo imagen...');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('[v0] Avatar subido: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('[v0] Error al subir la imagen: $e');
      throw Exception('Error al subir la imagen: $e');
    }
  }

  @override
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      print('[v0] deleteProfileImage - imageUrl: $imageUrl');
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('[v0] Avatar eliminado');
    } catch (e) {
      print('[v0] No se encontró avatar para eliminar o error: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
