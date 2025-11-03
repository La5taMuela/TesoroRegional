import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesoro_regional/core/services/auth/firebase_auth_service.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';

// Provider del servicio de autenticación
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return getIt<FirebaseAuthService>();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  print('[v0] authStateProvider - Escuchando cambios de autenticación');
  return authService.authStateChanges;
});

// Provider para verificar si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider del usuario actual
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});