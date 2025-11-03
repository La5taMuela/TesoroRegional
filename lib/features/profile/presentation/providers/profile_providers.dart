// Providers de Riverpod para inyección de dependencias
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';
import 'package:tesoro_regional/features/profile/domain/repositories/profile_repository.dart';
import 'package:tesoro_regional/features/profile/presentation/state/profile_notifier.dart';
import 'package:tesoro_regional/features/profile/presentation/state/profile_state.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';

// Provider del repositorio
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return getIt<ProfileRepository>();
});

// Provider del notifier
final profileNotifierProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

final profileStreamProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(profileRepositoryProvider);

  if (user == null) {
    print('[v0] profileStreamProvider: No hay usuario autenticado');
    return Stream.value(null);
  }

  print('[v0] profileStreamProvider: Escuchando cambios para usuario ${user.uid}');
  return repository.watchProfile(user.uid).map((either) {
    return either.fold(
          (failure) {
        print('[v0] profileStreamProvider: Error - ${failure.message}');
        return null;
      },
          (profile) {
        print('[v0] profileStreamProvider: Perfil actualizado - ${profile?.name}');
        return profile;
      },
    );
  });
});
