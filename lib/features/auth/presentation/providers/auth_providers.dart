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
  print('[v0] authStateProvider - Escuchando cambios de autenticación');
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

final isAdminProvider = FutureProvider<bool>((ref) async {
  print('[v0] isAdminProvider - Verificando si el usuario es admin');
  final user = ref.watch(currentUserProvider);

  if (user == null || user.email == null) {
    print('[v0] isAdminProvider - No hay usuario autenticado o sin email');
    return false;
  }

  try {
    final firestore = FirebaseFirestore.instanceFor(
      app: FirebaseFirestore.instance.app,
      databaseId: 'tesororegional',
    );

    final adminQuery = await firestore
        .collection('admins')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    final isAdmin = adminQuery.docs.isNotEmpty;
    print('[v0] isAdminProvider - Usuario ${user.email} es admin: $isAdmin');

    return isAdmin;
  } catch (e) {
    print('[v0] isAdminProvider - Error al verificar admin: $e');
    return false;
  }
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  print('[v0] userRoleProvider - Obteniendo rol del usuario');
  final user = ref.watch(currentUserProvider);

  if (user == null || user.email == null) {
    return null;
  }

  try {
    final firestore = FirebaseFirestore.instanceFor(
      app: FirebaseFirestore.instance.app,
      databaseId: 'tesororegional',
    );

    final adminQuery = await firestore
        .collection('admins')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (adminQuery.docs.isNotEmpty) {
      print('[v0] userRoleProvider - Rol: admin');
      return 'admin';
    }

    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      print('[v0] userRoleProvider - Rol: user');
      return 'user';
    }

    print('[v0] userRoleProvider - Rol: no encontrado');
    return null;
  } catch (e) {
    print('[v0] userRoleProvider - Error al obtener rol: $e');
    return null;
  }
});
