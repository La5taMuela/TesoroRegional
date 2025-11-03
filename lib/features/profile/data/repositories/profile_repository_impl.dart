// Repository Implementation - Implementa la lógica de negocio
import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';
import 'package:tesoro_regional/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:tesoro_regional/features/profile/data/models/user_profile_dto.dart';
import 'package:tesoro_regional/features/profile/domain/entities/user_profile.dart';
import 'package:tesoro_regional/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String userId) async {
    try {
      final profileDTO = await remoteDataSource.getProfile(userId);
      return Right(profileDTO?.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile(UserProfile profile) async {
    try {
      final profileDTO = UserProfileDTO.fromEntity(profile);
      await remoteDataSource.saveProfile(profileDTO);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
      String userId, File imageFile) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(userId, imageFile);
      return Right(imageUrl);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfileImage(String imageUrl) async {
    try {
      await remoteDataSource.deleteProfileImage(imageUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, UserProfile?>> watchProfile(String userId) {
    try {
      return remoteDataSource.watchProfile(userId).transform(
        StreamTransformer.fromHandlers(
          handleData: (profileDTO, sink) {
            sink.add(Right(profileDTO?.toEntity()));
          },
          handleError: (error, stackTrace, sink) {
            sink.add(Left(ServerFailure(message: error.toString())));
          },
        ),
      );
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }
}
