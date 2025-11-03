// Repository Interface - Define el contrato para las operaciones del perfil
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile(String userId);
  Stream<Either<Failure, UserProfile?>> watchProfile(String userId);
  Future<Either<Failure, void>> saveProfile(UserProfile profile);
  Future<Either<Failure, String>> uploadProfileImage(String userId, File imageFile);
  Future<Either<Failure, void>> deleteProfileImage(String imageUrl);
}
