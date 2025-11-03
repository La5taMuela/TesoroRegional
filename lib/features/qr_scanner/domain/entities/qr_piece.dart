import 'package:hive/hive.dart';
import '../../../../core/utils/qr_utils.dart';

part 'qr_piece.g.dart';

@HiveType(typeId: 0)
class QRPiece {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String province;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String code;
  @HiveField(4)
  final DateTime collectedAt;
  @HiveField(5)
  final bool isCollected;
  @HiveField(6) // Nuevo campo para Hive
  final String? imageUrl;

  QRPiece({
    required this.id,
    required this.province,
    required this.title,
    required this.code,
    required this.collectedAt,
    required this.isCollected,
    this.imageUrl, // Agregar imageUrl como parámetro opcional
  });

  factory QRPiece.fromQRData(QRPieceData data) {
    return QRPiece(
      id: '${data.province}_${data.title}_${data.code}',
      province: data.province,
      title: data.title,
      code: data.code,
      collectedAt: DateTime.now(),
      isCollected: true,
      imageUrl: null, // Se asignará después según los datos predefinidos
    );
  }

  // Método copyWith para crear copias con modificaciones
  QRPiece copyWith({
    String? id,
    String? province,
    String? title,
    String? code,
    DateTime? collectedAt,
    bool? isCollected,
    String? imageUrl,
  }) {
    return QRPiece(
      id: id ?? this.id,
      province: province ?? this.province,
      title: title ?? this.title,
      code: code ?? this.code,
      collectedAt: collectedAt ?? this.collectedAt,
      isCollected: isCollected ?? this.isCollected,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Método toJson para compatibilidad con SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'title': title,
      'code': code,
      'collectedAt': collectedAt.toIso8601String(),
      'isCollected': isCollected,
      'imageUrl': imageUrl,
    };
  }

  // Factory fromJson para compatibilidad con SharedPreferences
  factory QRPiece.fromJson(Map<String, dynamic> json) {
    return QRPiece(
      id: json['id'] as String,
      province: json['province'] as String,
      title: json['title'] as String,
      code: json['code'] as String,
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      isCollected: json['isCollected'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // Override de equality para comparaciones
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRPiece &&
        other.id == id &&
        other.province == province &&
        other.title == title &&
        other.code == code &&
        other.collectedAt == collectedAt &&
        other.isCollected == isCollected &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      province,
      title,
      code,
      collectedAt,
      isCollected,
      imageUrl,
    );
  }

  @override
  String toString() {
    return 'QRPiece(id: $id, province: $province, title: $title, code: $code, collectedAt: $collectedAt, isCollected: $isCollected, imageUrl: $imageUrl)';
  }
}
