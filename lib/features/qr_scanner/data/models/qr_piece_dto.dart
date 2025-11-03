import 'package:tesoro_regional/features/qr_scanner/domain/entities/qr_piece.dart';

class QRPieceDTO {
  final String id;
  final String province;
  final String title;
  final String code;
  final String collectedAt;
  final bool isCollected;

  QRPieceDTO({
    required this.id,
    required this.province,
    required this.title,
    required this.code,
    required this.collectedAt,
    required this.isCollected,
  });

  factory QRPieceDTO.fromEntity(QRPiece piece) {
    return QRPieceDTO(
      id: piece.id,
      province: piece.province,
      title: piece.title,
      code: piece.code,
      collectedAt: piece.collectedAt.toIso8601String(),
      isCollected: piece.isCollected,
    );
  }

  QRPiece toEntity() {
    return QRPiece(
      id: id,
      province: province,
      title: title,
      code: code,
      collectedAt: DateTime.parse(collectedAt),
      isCollected: isCollected,
    );
  }
}