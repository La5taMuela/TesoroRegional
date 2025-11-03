import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tesoro_regional/core/services/storage/storage_service.dart';
import 'package:tesoro_regional/core/services/logger/logger_service.dart';
import 'package:tesoro_regional/core/services/network/network_service.dart';
import 'package:tesoro_regional/core/services/location/location_service.dart';
import 'package:tesoro_regional/core/services/analytics/analytics_service.dart';
import 'package:tesoro_regional/core/services/auth/auth_service.dart';
import 'package:tesoro_regional/core/services/content/content_service.dart';
import 'package:tesoro_regional/core/services/qr/qr_scanner_service.dart';
import 'package:tesoro_regional/features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'package:tesoro_regional/features/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'package:tesoro_regional/features/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:tesoro_regional/features/qr_scanner/data/datasources/qr_local_data_source.dart';
import 'package:tesoro_regional/features/qr_scanner/domain/repositories/qr_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesoro_regional/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:tesoro_regional/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:tesoro_regional/features/profile/domain/repositories/profile_repository.dart';
import 'package:tesoro_regional/core/services/auth/firebase_auth_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    try {
      // Initialize Hive first
      await Hive.initFlutter();

      // Initialize SharedPreferences FIRST and register as singleton
      final sharedPreferences = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(sharedPreferences);

      // Core services - register in dependency order
      getIt.registerLazySingleton<LoggerService>(() => LoggerService());
      getIt.registerLazySingleton<StorageService>(() => StorageServiceImpl());

      // Network service needs logger
      getIt.registerLazySingleton<NetworkService>(() => NetworkServiceImpl(
        logger: getIt<LoggerService>(),
      ));

      // Location service - register BEFORE using it
      getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());

      // Analytics service needs storage and network
      getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsServiceImpl(
        storage: getIt<StorageService>(),
        network: getIt<NetworkService>(),
      ));

      // Auth service needs storage and network
      getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl(
        storage: getIt<StorageService>(),
        network: getIt<NetworkService>(),
      ));

      // Content service
      getIt.registerLazySingleton<ContentService>(() => ContentService());

      // QR Scanner service
      getIt.registerLazySingleton<QRScannerService>(() => QRScannerService());

      // Initialize QR data source and register it
      final qrDataSource = QRLocalDataSource();
      await qrDataSource.init();
      getIt.registerSingleton<QRLocalDataSource>(qrDataSource);

      // QR Repository
      getIt.registerLazySingleton<QRRepository>(() => QRLocalRepository(getIt<QRLocalDataSource>()));

      // Puzzle Data sources
      getIt.registerLazySingleton<PuzzleLocalDataSource>(() => PuzzleLocalDataSourceImpl(getIt<StorageService>()));

      // Puzzle Repository
      getIt.registerLazySingleton<PuzzleRepository>(() => PuzzleRepositoryImpl(
        localDataSource: getIt<PuzzleLocalDataSource>(),
        qrRepository: getIt<QRRepository>(),
        qrScannerService: getIt<QRScannerService>(),
      ));

      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'tesororegional',
      );
      getIt.registerSingleton<FirebaseFirestore>(firestore);

      getIt.registerLazySingleton<FirebaseAuthService>(
            () => FirebaseAuthServiceImpl(firestore: firestore),
      );

      // Profile Data Source
      getIt.registerLazySingleton<ProfileRemoteDataSource>(
            () => ProfileRemoteDataSourceImpl(
          firestore: getIt<FirebaseFirestore>(),
        ),
      );

      // Profile Repository
      getIt.registerLazySingleton<ProfileRepository>(
            () => ProfileRepositoryImpl(
          remoteDataSource: getIt<ProfileRemoteDataSource>(),
        ),
      );

      print('✅ ServiceLocator: All services registered successfully');
    } catch (e, stackTrace) {
      print('❌ ServiceLocator initialization failed: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
