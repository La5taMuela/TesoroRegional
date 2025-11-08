// core/database/firestore_config.dart

/// Configuración centralizada para los nombres de colecciones de Firestore
class FirestoreConfig {
  // Colecciones de usuarios
  static const String usersCollection = 'users';
  static const String adminsCollection = 'admins';
  static const String pymesCollection = 'pymes';
  static const String empresasCollection = 'empresas';

  // Colecciones de contenido
  static const String postsCollection = 'posts';
  static const String contentCollection = 'content';
  static const String piecesCollection = 'pieces';

  // Otras colecciones
  static const String commentsCollection = 'comments';
  static const String notificationsCollection = 'notifications';
  static const String missionsCollection = 'missions';
  static const String storiesCollection = 'stories';

  // Campos comunes
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String statusField = 'status';
  static const String uidField = 'uid';
}