import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesoro_regional/core/services/auth/firebase_auth_service.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return getIt<FirebaseAuthService>();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  print('[v1] authStateProvider - Escuchando cambios de autenticación');
  return authService.authStateChanges;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider más eficiente que verifica el rol una sola vez por usuario
final userRoleProvider = FutureProvider<String?>((ref) async {
  print('[v1] userRoleProvider - Iniciando verificación de rol');

  final authState = ref.watch(authStateProvider);

  // Esperar a que el estado de auth esté disponible usando when()
  return authState.when(
    data: (user) async {
      if (user == null || user.email == null) {
        print('[v1] userRoleProvider - No hay usuario autenticado');
        return null;
      }

      print('[v1] userRoleProvider - Usuario autenticado: ${user.email}');

      try {
        final firestore = FirebaseFirestore.instanceFor(
          app: FirebaseFirestore.instance.app,
          databaseId: 'tesororegional',
        );

        // Verificar si es admin primero (más rápido)
        print('[v1] userRoleProvider - Verificando si es admin...');
        final adminDoc = await firestore
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          print('[v1] userRoleProvider - ✅ Usuario es ADMIN');
          return 'admin';
        }

        // Si no es admin, verificar si es usuario normal
        print('[v1] userRoleProvider - Verificando si es usuario normal...');
        final userDoc = await firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          print('[v1] userRoleProvider - ✅ Usuario es USER');
          return 'user';
        }

        print('[v1] userRoleProvider - ⚠️ Usuario sin rol definido');
        return 'user'; // Por defecto, tratar como usuario normal
      } catch (e) {
        print('[v1] userRoleProvider - ❌ Error al obtener rol: $e');
        return 'user'; // En caso de error, tratar como usuario normal
      }
    },
    loading: () {
      print('[v1] userRoleProvider - Auth state aún cargando');
      return null;
    },
    error: (error, stackTrace) {
      print('[v1] userRoleProvider - ❌ Error en auth state: $error');
      return 'user'; // En caso de error, tratar como usuario normal
    },
  );
});

// Provider auxiliar para verificación rápida de admin (compatible con código existente)
final isAdminProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return role == 'admin';
});