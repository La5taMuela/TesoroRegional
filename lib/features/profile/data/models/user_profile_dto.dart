// Data Transfer Object para convertir entre Firestore y la entidad
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesoro_regional/features/profile/domain/entities/user_profile.dart';

class UserProfileDTO {
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

  UserProfileDTO({
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

  // Convertir desde Firestore
  factory UserProfileDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileDTO(
      id: doc.id,
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      alias: data['alias'],
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      country: data['country'],
      description: data['description'],
      interests: List<String>.from(data['interests'] ?? []),
      profileImageUrl: data['profileImageUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'lastName': lastName,
      'alias': alias,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'country': country,
      'description': description,
      'interests': interests,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convertir a entidad de dominio
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      lastName: lastName,
      alias: alias,
      birthDate: birthDate,
      country: country,
      description: description,
      interests: interests,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Crear desde entidad de dominio
  factory UserProfileDTO.fromEntity(UserProfile profile) {
    return UserProfileDTO(
      id: profile.id,
      name: profile.name,
      lastName: profile.lastName,
      alias: profile.alias,
      birthDate: profile.birthDate,
      country: profile.country,
      description: profile.description,
      interests: profile.interests,
      profileImageUrl: profile.profileImageUrl,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}
