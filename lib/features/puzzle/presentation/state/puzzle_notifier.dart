import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/features/puzzle/presentation/state/puzzle_state.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/cultural_piece.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/piece_category.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/geo_position.dart';
import 'package:tesoro_regional/features/puzzle/domain/entities/language_localized.dart';
import 'package:tesoro_regional/features/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'package:tesoro_regional/features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'package:tesoro_regional/features/puzzle/data/datasources/puzzle_remote_data_source.dart';
import 'package:tesoro_regional/core/services/storage/storage_service.dart';
import 'package:tesoro_regional/core/services/network/network_service.dart';
import 'package:tesoro_regional/core/services/logger/logger_service.dart';
import 'package:tesoro_regional/core/utils/typedefs.dart';

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  late final PuzzleRepositoryImpl _repository;

  PuzzleNotifier() : super(const PuzzleInitial()) {
    // Initialize repository with dependencies
    final storageService = StorageServiceImpl();
    final networkService = NetworkServiceImpl(logger: LoggerService());
    final localDataSource = PuzzleLocalDataSourceImpl(storageService);
    final remoteDataSource = PuzzleRemoteDataSourceImpl(networkService);

    _repository = PuzzleRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  }

  Future<void> loadPuzzleData() async {
    state = const PuzzleLoading();

    try {
      // Load categories and pieces from repository
      final categoriesResult = await _repository.getCategories();
      final piecesResult = await _repository.getCollectedPieces();
      final percentageResult = await _repository.getOverallCompletionPercentage();

      categoriesResult.fold(
            (failure) => state = PuzzleError(failure.message),
            (categories) {
          piecesResult.fold(
                (failure) => state = PuzzleError(failure.message),
                (pieces) {
              percentageResult.fold(
                    (failure) => state = PuzzleError(failure.message),
                    (percentage) {
                  state = PuzzleLoaded(
                    categories: categories,
                    collectedPieces: pieces,
                    completionPercentage: percentage,
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      state = PuzzleError(e.toString());
    }
  }

  Future<CulturalPiece?> collectPieceByQr(String qrCode) async {
    try {
      final result = await _repository.collectPieceByQr(qrCode);

      return result.fold(
            (failure) {
          // Handle failure but don't change the main state
          return null;
        },
            (piece) {
          // Reload puzzle data to reflect the new piece
          loadPuzzleData();
          return piece;
        },
      );
    } catch (e) {
      return null;
    }
  }

  void selectCategory(String categoryId) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      state = currentState.copyWith(selectedCategoryId: categoryId);
    }
  }
}
