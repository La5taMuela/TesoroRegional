// Estado del perfil para Riverpod
import 'package:tesoro_regional/features/profile/domain/entities/user_profile.dart';

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool? isSaving,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
