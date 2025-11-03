// Controlador (Controller) - Maneja la lógica de presentación con Riverpod
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/features/profile/domain/entities/user_profile.dart';
import 'package:tesoro_regional/features/profile/domain/repositories/profile_repository.dart';
import 'package:tesoro_regional/features/profile/presentation/state/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  // Cargar perfil desde Firestore
  Future<void> loadProfile(String userId) async {
    print('[v0] ProfileNotifier.loadProfile - userId: $userId');
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getProfile(userId);

    result.fold(
          (failure) {
        print('[v0] Error al cargar perfil: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
          (profile) {
        print('[v0] Perfil cargado exitosamente: ${profile?.name ?? "null"}');
        state = state.copyWith(
          isLoading: false,
          profile: profile ?? UserProfile.empty(userId),
        );
      },
    );
  }

  // Guardar perfil en Firestore
  Future<bool> saveProfile({
    required String userId,
    required String name,
    required String lastName,
    String? alias,
    DateTime? birthDate,
    String? country,
    String? description,
    List<String>? interests,
  }) async {
    print('[v0] ProfileNotifier.saveProfile - userId: $userId');
    print('[v0] Datos: name=$name, lastName=$lastName, alias=$alias');

    state = state.copyWith(isSaving: true, error: null);

    final updatedProfile = (state.profile ?? UserProfile.empty(userId)).copyWith(
      name: name,
      lastName: lastName,
      alias: alias,
      birthDate: birthDate,
      country: country,
      description: description,
      interests: interests,
      updatedAt: DateTime.now(),
    );

    print('[v0] Perfil actualizado a guardar: ${updatedProfile.name}');
    final result = await _repository.saveProfile(updatedProfile);

    return result.fold(
          (failure) {
        print('[v0] Error al guardar perfil: ${failure.message}');
        state = state.copyWith(
          isSaving: false,
          error: failure.message,
        );
        return false;
      },
          (_) {
        print('[v0] Perfil guardado exitosamente en el notifier');
        state = state.copyWith(
          isSaving: false,
          profile: updatedProfile,
        );
        return true;
      },
    );
  }

  // Subir imagen de perfil
  Future<bool> uploadProfileImage(String userId, File imageFile) async {
    print('[v0] ProfileNotifier.uploadProfileImage - userId: $userId');
    state = state.copyWith(isSaving: true, error: null);

    if (state.profile?.profileImageUrl != null) {
      print('[v0] Eliminando imagen anterior...');
      await _repository.deleteProfileImage(state.profile!.profileImageUrl!);
    }

    final result = await _repository.uploadProfileImage(userId, imageFile);

    return result.fold(
          (failure) {
        print('[v0] Error al subir imagen: ${failure.message}');
        state = state.copyWith(
          isSaving: false,
          error: failure.message,
        );
        return false;
      },
          (imageUrl) async {
        print('[v0] Imagen subida, actualizando perfil con URL: $imageUrl');
        final updatedProfile = state.profile!.copyWith(
          profileImageUrl: imageUrl,
          updatedAt: DateTime.now(),
        );

        final saveResult = await _repository.saveProfile(updatedProfile);

        return saveResult.fold(
              (failure) {
            print('[v0] Error al guardar perfil con nueva imagen: ${failure.message}');
            state = state.copyWith(
              isSaving: false,
              error: failure.message,
            );
            return false;
          },
              (_) {
            print('[v0] Perfil actualizado con nueva imagen exitosamente');
            state = state.copyWith(
              isSaving: false,
              profile: updatedProfile,
            );
            return true;
          },
        );
      },
    );
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
