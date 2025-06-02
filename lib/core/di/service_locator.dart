import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/core/services/logger/logger_service.dart';
import 'package:tesoro_regional/core/services/storage/storage_service.dart';
import 'package:tesoro_regional/core/services/location/location_service.dart';
import 'package:tesoro_regional/core/services/qr/qr_scanner_service.dart';
import 'package:tesoro_regional/core/services/network/network_service.dart';
import 'package:tesoro_regional/core/services/auth/auth_service.dart';
import 'package:tesoro_regional/core/services/analytics/analytics_service.dart';

// Create a singleton logger
final loggerService = LoggerService();

// Setup function for service locator
Future<void> setupServiceLocator() async {
  // Initialize any services that need async setup
  // For now, this is just a placeholder
}

// Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageServiceImpl();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

final qrScannerServiceProvider = Provider<QRScannerService>((ref) {
  return QRScannerServiceImpl();
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  final logger = loggerService;
  return NetworkServiceImpl(logger: logger);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final network = ref.watch(networkServiceProvider);
  return AuthServiceImpl(storage: storage, network: network);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final network = ref.watch(networkServiceProvider);
  return AnalyticsServiceImpl(
    storage: storage,
    network: network,
  );
});
