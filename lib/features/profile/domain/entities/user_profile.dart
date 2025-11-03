// Modelo (Model) - Entidad de dominio para el perfil de usuario
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String lastName;
  final String? alias;
  final DateTime? birthDate;
  final String? country;
  final String? description;
  final List<String> interests;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.lastName,
    this.alias,
    this.birthDate,
    this.country,
    this.description,
    this.interests = const [],
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Método para crear una copia con cambios
  UserProfile copyWith({
    String? id,
    String? name,
    String? lastName,
    String? alias,
    DateTime? birthDate,
    String? country,
    String? description,
    List<String>? interests,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      alias: alias ?? this.alias,
      birthDate: birthDate ?? this.birthDate,
      country: country ?? this.country,
      description: description ?? this.description,
      interests: interests ?? this.interests,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Perfil vacío para inicialización
  factory UserProfile.empty(String userId) {
    final now = DateTime.now();
    return UserProfile(
      id: userId,
      name: '',
      lastName: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    lastName,
    alias,
    birthDate,
    country,
    description,
    interests,
    profileImageUrl,
    createdAt,
    updatedAt,
  ];
}
