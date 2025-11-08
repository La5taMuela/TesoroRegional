// core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  static final FirebaseFirestore _instance = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tesororegional', // Tu nombre de base de datos
  );

  static FirebaseFirestore get instance => _instance;

  // Métodos de ayuda para colecciones comunes
  static CollectionReference get users => _instance.collection('users');
  static CollectionReference get admins => _instance.collection('admins');
  static CollectionReference get pymes => _instance.collection('pymes');
  static CollectionReference get empresas => _instance.collection('empresas');
  static CollectionReference get posts => _instance.collection('posts');
  static CollectionReference get pieces => _instance.collection('pieces');

  // Método genérico para cualquier colección
  static CollectionReference collection(String collectionName) {
    return _instance.collection(collectionName);
  }
}