import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseAuthService {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<User?> signInWithGoogle();
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String lastName);
  Future<void> signOut();
  bool get isAuthenticated;
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> reloadUser();
  bool get isEmailVerified;
  Future<void> reauthenticateWithPassword(String password);
  Future<void> deleteAccount();
}

class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseAuthServiceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']),
        _firestore = firestore ??
            FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'tesororegional',
            ),
        _storage = storage ?? FirebaseStorage.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  Future<User?> signInWithGoogle() async {
    try {
      print('[v0] Iniciando signInWithGoogle...');

      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      print('[v0] signInSilently resultado: ${googleUser?.email ?? "null"}');

      // Si no hay sesión silenciosa, mostrar el diálogo de inicio de sesión
      googleUser ??= await _googleSignIn.signIn();
      print('[v0] signIn resultado: ${googleUser?.email ?? "null"}');

      if (googleUser == null) {
        print('[v0] Usuario canceló el inicio de sesión');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('[v0] GoogleAuth obtenido');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('[v0] Credential creado');

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('[v0] UserCredential obtenido: ${userCredential.user?.uid}');

      final user = userCredential.user;

      if (user != null) {
        print('[v0] Creando/actualizando usuario en Firestore...');
        await _createOrUpdateUser(
          userId: user.uid,
          email: user.email!,
          nombre: user.displayName?.split(' ').first,
          apellido: user.displayName?.split(' ').skip(1).join(' '),
          avatarURL: user.photoURL,
        );
        print('[v0] Usuario creado/actualizado exitosamente');
      }

      return user;
    } catch (e) {
      print('[v0] Error en signInWithGoogle: $e');
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('[v0] Iniciando signInWithEmailAndPassword...');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('[v0] Usuario autenticado: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('[v0] FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('ACCOUNT_NOT_FOUND');
        case 'invalid-credential':
        case 'wrong-password':
          throw Exception('INVALID_CREDENTIALS');
        case 'invalid-email':
          throw Exception('Correo electrónico inválido');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        default:
          throw Exception('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      print('[v0] Error en signInWithEmailAndPassword: $e');
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
      String email,
      String password,
      String name,
      String lastName,
      ) async {
    try {
      print('[v0] Iniciando signUpWithEmailAndPassword...');
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        print('[v0] Usuario creado: ${user.uid}');
        await user.updateDisplayName('$name $lastName');

        await user.sendEmailVerification();
        print('[v0] Email de verificación enviado');

        await _createOrUpdateUser(
          userId: user.uid,
          email: email,
          nombre: name,
          apellido: lastName,
        );
        print('[v0] Usuario creado en Firestore');

        await Future.delayed(const Duration(milliseconds: 500));
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('[v0] FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Ya existe una cuenta con este correo');
        case 'invalid-email':
          throw Exception('Correo electrónico inválido');
        case 'weak-password':
          throw Exception('La contraseña debe tener al menos 6 caracteres');
        default:
          throw Exception('Error al crear cuenta: ${e.message}');
      }
    } catch (e) {
      print('[v0] Error en signUpWithEmailAndPassword: $e');
      throw Exception('Error al crear cuenta: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('[v0] Cerrando sesión...');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('[v0] Sesión cerrada exitosamente');
    } catch (e) {
      print('[v0] Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('[v0] Email de verificación enviado a ${user.email}');
      }
    } catch (e) {
      print('[v0] Error al enviar email de verificación: $e');
      throw Exception('Error al enviar email de verificación: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('[v0] Email de restablecimiento enviado a $email');
    } on FirebaseAuthException catch (e) {
      print('[v0] FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No existe una cuenta con este correo');
        case 'invalid-email':
          throw Exception('Correo electrónico inválido');
        default:
          throw Exception('Error al enviar email: ${e.message}');
      }
    } catch (e) {
      print('[v0] Error al enviar email de restablecimiento: $e');
      throw Exception('Error al enviar email de restablecimiento: $e');
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      print('[v0] Usuario recargado');
    } catch (e) {
      print('[v0] Error al recargar usuario: $e');
      throw Exception('Error al recargar usuario: $e');
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No hay usuario autenticado');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('[v0] Usuario reautenticado exitosamente');
    } on FirebaseAuthException catch (e) {
      print('[v0] FirebaseAuthException en reautenticación: ${e.code}');
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Contraseña incorrecta');
        case 'user-mismatch':
          throw Exception('Las credenciales no coinciden con el usuario actual');
        case 'user-not-found':
          throw Exception('Usuario no encontrado');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        default:
          throw Exception('Error al verificar contraseña: ${e.message}');
      }
    } catch (e) {
      print('[v0] Error al reautenticar: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.uid;
      print('[v0] Iniciando eliminación de cuenta para usuario: $userId');

      try {
        print('[v0] Eliminando archivos de metadata-users/$userId...');
        final metadataRef = _storage.ref().child('metadata-users/$userId');
        await _deleteAllFilesInFolder(metadataRef);
        print('[v0] Archivos de metadata-users eliminados');
      } catch (e) {
        print('[v0] Error al eliminar metadata-users (puede no existir): $e');
      }

      try {
        print('[v0] Eliminando archivos de users/$userId...');
        final usersRef = _storage.ref().child('users/$userId');
        await _deleteAllFilesInFolder(usersRef);
        print('[v0] Archivos de users eliminados');
      } catch (e) {
        print('[v0] Error al eliminar users (puede no existir): $e');
      }

      // 3. Eliminar documento de Firestore
      try {
        await _firestore.collection('users').doc(userId).delete();
        print('[v0] Documento de Firestore eliminado');
      } catch (e) {
        print('[v0] Error al eliminar documento de Firestore: $e');
      }

      // 4. Eliminar usuario de Authentication
      await user.delete();
      print('[v0] Usuario eliminado de Authentication');

      // 5. Cerrar sesión de Google si estaba conectado
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('[v0] No había sesión de Google activa');
      }

      print('[v0] Cuenta eliminada completamente');
    } on FirebaseAuthException catch (e) {
      print('[v0] FirebaseAuthException al eliminar cuenta: ${e.code}');
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('Por seguridad, debes volver a iniciar sesión antes de eliminar tu cuenta');
        default:
          throw Exception('Error al eliminar cuenta: ${e.message}');
      }
    } catch (e) {
      print('[v0] Error al eliminar cuenta: $e');
      rethrow;
    }
  }

  Future<void> _deleteAllFilesInFolder(Reference folderRef) async {
    try {
      print('[v0] Listando archivos en: ${folderRef.fullPath}');
      final listResult = await folderRef.listAll();

      // Eliminar todos los archivos
      for (var item in listResult.items) {
        try {
          await item.delete();
          print('[v0] ✓ Archivo eliminado: ${item.fullPath}');
        } catch (e) {
          print('[v0] ✗ Error al eliminar archivo ${item.fullPath}: $e');
        }
      }

      // Eliminar recursivamente todas las subcarpetas
      for (var prefix in listResult.prefixes) {
        print('[v0] Entrando a subcarpeta: ${prefix.fullPath}');
        await _deleteAllFilesInFolder(prefix);
      }

      print('[v0] Carpeta ${folderRef.fullPath} procesada completamente');
    } catch (e) {
      print('[v0] Error al procesar carpeta ${folderRef.fullPath}: $e');
      // No lanzar error, continuar con la eliminación
    }
  }

  Future<void> _createOrUpdateUser({
    required String userId,
    required String email,
    String? nombre,
    String? apellido,
    String? alias,
    DateTime? fechaNacimiento,
    String? pais,
    String? descripcion,
    String? avatarURL,
    List<String>? intereses,
  }) async {
    try {
      print('[v0] _createOrUpdateUser - userId: $userId');
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        print('[v0] Usuario no existe, creando nuevo documento...');
        await userRef.set({
          'id': userId,
          'tipo': 'normal',
          'email': email,
          'name': nombre ?? '',
          'lastName': apellido ?? '',
          'alias': alias ?? '',
          'birthDate': fechaNacimiento,
          'country': pais ?? '',
          'description': descripcion ?? '',
          'profileImageUrl': avatarURL ?? '', // Google photo URL by default
          'interests': intereses ?? [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('[v0] Usuario creado en Firestore: $userId');
      } else {
        print('[v0] Usuario existe, actualizando campos proporcionados...');
        final updateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (nombre != null) updateData['name'] = nombre;
        if (apellido != null) updateData['lastName'] = apellido;
        if (alias != null) updateData['alias'] = alias;
        if (fechaNacimiento != null) updateData['birthDate'] = fechaNacimiento;
        if (pais != null) updateData['country'] = pais;
        if (descripcion != null) updateData['description'] = descripcion;
        if (avatarURL != null) {
          final currentData = userDoc.data();
          if (currentData?['profileImageUrl'] == null || currentData?['profileImageUrl'] == '') {
            updateData['profileImageUrl'] = avatarURL;
          }
        }
        if (intereses != null) updateData['interests'] = intereses;

        if (updateData.isNotEmpty) {
          await userRef.update(updateData);
          print('[v0] Usuario actualizado en Firestore: $userId');
        }
      }
    } catch (e) {
      print('[v0] Error al crear/actualizar usuario: $e');
      rethrow;
    }
  }
}
