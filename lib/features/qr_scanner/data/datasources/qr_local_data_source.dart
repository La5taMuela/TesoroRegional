import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';
import 'package:hive/hive.dart';

class QRLocalDataSource {
  static const _boxName = 'qrPiecesBox';
  late Box<QRPiece> _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        if (!Hive.isAdapterRegistered(0)) {
          Hive.registerAdapter(QRPieceAdapter());
        }
        _box = await Hive.openBox<QRPiece>(_boxName);
        _isInitialized = true;
      } catch (e) {
        print('Error initializing QR local data source: $e');
        throw Exception('Failed to initialize QR storage: $e');
      }
    }
  }

  Future<void> savePiece(QRPiece piece) async {
    try {
      await init(); // Ensure initialized
      await _box.put(piece.id, piece);
    } catch (e) {
      print('Error saving QR piece: $e');
      throw Exception('Failed to save QR piece: $e');
    }
  }

  Future<List<QRPiece>> getAllPieces() async {
    try {
      await init(); // Ensure initialized
      return _box.values.toList();
    } catch (e) {
      print('Error getting all QR pieces: $e');
      return [];
    }
  }

  Future<QRPiece?> getPieceById(String id) async {
    try {
      await init(); // Ensure initialized
      return _box.get(id);
    } catch (e) {
      print('Error getting QR piece by id: $e');
      return null;
    }
  }

  Future<int> getCollectedCount() async {
    try {
      await init(); // Ensure initialized
      return _box.values.where((piece) => piece.isCollected).length;
    } catch (e) {
      print('Error getting collected count: $e');
      return 0;
    }
  }

  Future<void> close() async {
    try {
      if (_isInitialized && _box.isOpen) {
        await _box.close();
        _isInitialized = false;
      }
    } catch (e) {
      print('Error closing QR box: $e');
    }
  }
}
